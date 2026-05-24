--- simirian's Neovim
--- generic picker plugin

local async = require("async")
local pick = require("pick")

--- @type integer
local ns = vim.api.nvim_create_namespace("pick")

--- The arguments required to set up a new picker.
--- @class Pick.Args<T>
--- A list of items to pick from, or a function to generate them in an async
--- context. If a function, then `coroutine.yield()` may be used freely.
--- @field list T[] | fun(): T[]
--- The function used to sort the items in the list based on the user's prompt.
--- The function is called in an async context, so `coroutine.yield()` may be
--- used freely.
--- @field sort fun(items: T[], prompt: string): T[]
--- The function used to convert each item to a string for display. Default
--- value is `tostring()`.
--- @field display? fun(item: T, idx: integer): string
--- The function used to populate the preview window. This function is expected
--- to put something in the preview window, but there is no prior expectation as
--- to what that thing is. The window is pre-populated with an empty dummy
--- buffer whose lines can be set.
--- @field preview? fun(item: T, idx: integer, winid: integer)
--- Function which can move entries to the quickfix list.
--- @field toquickfix? fun(item: T, idx: integer): vim.quickfix.entry
--- Callback for when the user confirms their selection.
--- @field confirm fun(item: T, idx: integer)

--- Prompt user to select an item from a list.
--- @generic T
--- @param list T[]
--- @param opts vim.ui.select.Opts
--- @param on_choice fun(item: T, idx: integer)
--- @diagnostic disable-next-line: duplicate-set-field
vim.ui.select = function(list, opts, on_choice)
  pick.pick({
    list = list,
    sort = pick.match,
    display = opts.format_item or tostring,
    confirm = on_choice,
  })
end

local pickers = {}

--- Opens a picker prompt whose input is forwarded to ripgrep.
function pickers.grep()
  local bufs = {}
  pick.pick({
    list = {},
    sort = function(_, prompt)
      local out = async.system({ "rg", "--vimgrep", "-Se", prompt == "" and ".*" or prompt }, {})
      if not out then return {} end
      if out.code == 0 then
        return vim.split(out.stdout, "[\r\n]+", { trimempty = true })
      else
        return {}
      end
    end,
    toquickfix = function(item)
      local name, line, col = item:match("^([^:]+):(%d+):(%d+):.*$")
      return { filename = name, lnum = line, col = col }
    end,
    preview = function(item, _, winid)
      local name, line, col = item:match("^([^:]+):(%d+):(%d+):.*$")
      if name and line and col then
        -- open the file in the preview window
        vim.api.nvim_win_call(winid, function()
          local bufnr = vim.fn.bufnr(name)
          if bufnr ~= -1 then
            vim.cmd.buffer(bufnr)
          else
            vim.cmd.edit(name)
          end
          line = tonumber(line) or 0
          col = tonumber(col) or 0
          vim.api.nvim_win_set_cursor(winid, { line, col })
        end)
        -- clear old marks
        for _, bufnr in ipairs(bufs) do
          vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
        end
        -- mark the searched line
        local bufnr = vim.fn.bufnr(name)
        table.insert(bufs, bufnr)
        vim.api.nvim_buf_set_extmark(bufnr, ns, line - 1, col, { line_hl_group = "Search" })
      end
    end,
    confirm = function(item)
      local name, line, col = item:match("^([^:]+):(%d+):(%d+):.*$")
      -- edit the file
      if name and line and col then
        vim.cmd.edit(name)
        vim.api.nvim_win_set_cursor(0, { tonumber(line), tonumber(col) })
      end
      -- clear marks
      for _, bufnr in ipairs(bufs) do
        vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
      end
    end,
  })
end

--- Opens a picker prompt for help tags.
function pickers.help()
  pick.pick({
    list = function()
      local tags = {}
      local files = vim.api.nvim_get_runtime_file("doc/tags", true)
      for _, file in ipairs(files) do
        local fd = vim.uv.fs_open(file, "r", 420)
        if not fd then return {} end
        local size = vim.uv.fs_fstat(fd).size
        local contents = vim.uv.fs_read(fd, size)
        vim.uv.fs_close(fd)
        if not contents then return {} end
        for tag, fname, pattern in contents:gmatch("([^\r\n\t]+)\t([^\r\n\t]+)\t([^\r\n\t]+)[\r\n]+") do
          if tag then
            table.insert(tags, {
              tag = tag,
              file = fname and vim.fs.normalize(file):match("^(.*/)") .. fname,
              pattern = pattern
            })
          end
        end
      end
      return tags
    end,
    sort = function(items, prompt) return pick.match(items, prompt, "tag") end,
    display = function(item) return item.tag end,
    preview = function(item, _, winid)
      if item.file then
        vim.api.nvim_win_call(winid, function()
          local bufnr = vim.fn.bufnr(item.file)
          if bufnr ~= -1 then
            vim.cmd.buffer(bufnr)
          else
            vim.cmd.edit(item.file)
          end
          if item.pattern then
            if item.pattern:find("/", 1, true) == 1 then -- search pattern
              vim.api.nvim_win_set_cursor(winid, { 1, 0 })
              local line = vim.fn.search("\\M" .. item.pattern:sub(2), "cw")
              vim.print(line)
            else -- line number
              vim.api.nvim_win_set_cursor(winid, { tonumber(item.pattern) or 1, 0 })
            end
          end
        end)
        local bufnr = vim.fn.bufnr(item.file)
        vim.bo[bufnr].buftype = "help"
        vim.bo[bufnr].modifiable = false
      end
    end,
    confirm = function(item) vim.cmd.help(item.tag) end,
  })
end

--- Pick from all files in the current directory excluding git files.
function pickers.files()
  pick.pick({
    list = function()
      local function lsr(path)
        local strs = {}
        for name, type in vim.fs.dir(path) do
          if name ~= ".git" or type ~= "directory" then
            coroutine.yield()
            local fname = path .. "/" .. name
            table.insert(strs, fname)
            if type == "directory" then
              vim.list_extend(strs, lsr(fname))
            end
          end
        end
        return strs
      end
      return vim.tbl_map(function(s) return s:sub(3) end, lsr("."))
    end,
    sort = pick.match,
    preview = function(item, _, winid)
      vim.api.nvim_win_call(winid, function()
        local bufnr = vim.fn.bufnr(item)
        if bufnr ~= -1 then
          vim.cmd.buffer(bufnr)
        else
          vim.cmd.edit(item)
        end
      end)
    end,
    toquickfix = function(item) return { filename = item } end,
    confirm = function(item) vim.cmd.edit(item) end,
  })
end

--- Opens a picker for listed vim buffers.
function pickers.buffers()
  pick.pick({
    list = function()
      local bufnrs = vim.api.nvim_list_bufs()
      local items = {}
      for _, bufnr in ipairs(bufnrs) do
        coroutine.yield()
        if vim.fn.buflisted(bufnr) == 1 then
          local bufname = vim.api.nvim_buf_get_name(bufnr)
          table.insert(items, {
            bufnr = bufnr,
            bufname = bufname,
            shortname = vim.b[bufnr].bufname or vim.fn.fnamemodify(bufname, ":~:."),
          })
        end
      end
      return items
    end,
    sort = function(items, prompt) return pick.match(items, prompt, "shortname") end,
    display = function(item) return item.shortname end,
    preview = function (item, _, winid)
      vim.api.nvim_win_call(winid, function()
        vim.cmd.buffer(item.bufnr)
      end)
    end,
    toquickfix = function(item) return { bufnr = item.bufnr, text = item.shortname } end,
    confirm = function(item) vim.cmd.buffer(item.bufnr) end,
  })
end

vim.api.nvim_create_user_command("Pick", function(args)
  local p = vim.g.pickers
  if p[args.args] then
    p[args.args]()
  end
end, {
  desc = "Use a picker.",
  nargs = "?",
  bang = true,
  complete = function(arglead, cmdline, curpos)
    local p = vim.g.pickers
    if curpos ~= #cmdline then return end
    return vim.tbl_filter(function(e)
      return vim.startswith(e, arglead)
    end, vim.tbl_keys(p))
  end,
})

vim.keymap.set("n", "<leader>ff", pickers.files, { desc = "Find files." })
vim.keymap.set("n", "<leader>fh", pickers.help, { desc = "Find help." })
vim.keymap.set("n", "<leader>fg", pickers.grep, { desc = "Find with grep." })
vim.keymap.set("n", "<leader>fb", pickers.buffers, { desc = "Find buffers." })
