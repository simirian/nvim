-- simirian's NeoVim
-- file explorer

local icons = require("icons")

vim.g.loaded_netrw = 1
vim.g.loaded_netrwplugin = 1

local M = {}
local H = {}

--- Gets an icon for a file based on its file name.
--- @param fname string The file name to get an icon for.
--- @return string icon
--- @return string highlight
function H.icon(fname)
  local devicons_ok, devicons = pcall(require, "nvim-web-devicons")
  if devicons_ok then
    return devicons.get_icon(fname, fname:match("[^%.]*$"))
  end
  return icons.files.file, "Normal"
end

--- A child of a fex directory buffer.
--- @class FexChild
--- The name of the child.
--- @field name string
--- The inode type of the child.
--- @field type string
--- If the child is a symlink or not.
--- @field link? boolean

--- Combines the name of a parent directory with a child safely, preserving
--- trailing slashes and normalizing the paths.
--- @param parent string|integer The parent path name or fex directory bufnr.
--- @param child string The name of the child.
--- @return string path
function H.get_child_path(parent, child)
  if type(parent) == "number" then
    parent = vim.api.nvim_buf_get_name(parent)
  end
  --- @cast parent string
  return vim.fs.normalize(vim.fs.joinpath(parent, child)) .. child:match("[/\\]?$")
end

--- Gets the children of a fex buffer.
--- @param bufnr integer The fex buffer to update children for.
--- @return FexChild[] children
function H.dir_get_children(bufnr)
  local dirname = vim.api.nvim_buf_get_name(bufnr)
  local children = {}
  for name, type in vim.fs.dir(dirname) do
    local link = type == "link"
    if link then
      --- @diagnostic disable-next-line: undefined-field
      local stat = vim.loop.fs_stat(H.get_child_path(dirname, name))
      type = stat.type
    end
    table.insert(children, {
      name = name,
      type = type,
      link = link,
    })
  end
  vim.b[bufnr].fex_children = children
  return children
end

--- Filters the children of a fex buffer.
--- @param children FexChild[] The children to be filtered.
--- @return FexChild[] children
function H.filter_children(children)
  return vim.tbl_filter(M.filter, children)
end

--- Sorts the children of a fex buffer.
--- @param children FexChild[] The children to sort.
--- @return FexChild[] children
function H.sort_children(children)
  local copy = vim.deepcopy(children)
  table.sort(copy, M.sort)
  return copy
end

--- Sets the lines in a fex buffer according to the cached children.
--- @param bufnr integer The fex buffer to update the content of.
function H.dir_set_lines(bufnr)
  local children = vim.b[bufnr].fex_children
  children = H.filter_children(children)
  children = H.sort_children(children)
  vim.b[bufnr].fex_visible = children
  local lines = {}
  for i, child in ipairs(children) do
    lines[i] = child.name
  end
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].modified = false
end

H.namespace = vim.api.nvim_create_namespace("fex")

--- Sets the extmarks to show file type icons in the fex buffer.
function H.dir_set_marks(bufnr)
  local children = vim.b[bufnr].fex_visible
  for lnum, child in ipairs(children) do
    local icon, hl, icohl
    if child.type == "directory" then
      hl = "Directory"
      icohl = "Directory"
      if child.link then
        icon = icons.files.link_directory
      else
        icon = icons.files.directory
      end
    else
      icon, icohl = H.icon(child.name)
      if not icon then
        icon = child.link and icons.files.link_file or icons.files.file
        icohl = "Normal"
      end
    end
    vim.api.nvim_buf_set_extmark(bufnr, H.namespace, lnum - 1, 0, {
      virt_text = { { icon .. " ", icohl } },
      virt_text_pos = "inline",
      invalidate = true,
      line_hl_group = hl,
    })
  end
end

H.augroup = vim.api.nvim_create_augroup("fex", { clear = true })
vim.api.nvim_create_autocmd("BufNew", {
  desc = "Set up fex buffers when they are opened.",
  group = H.augroup,
  callback = function(e)
    --- @diagnostic disable-next-line: undefined-field
    local stat = vim.loop.fs_stat(e.file)
    if not stat or stat.type ~= "directory" then return end

    vim.api.nvim_create_autocmd("BufReadCmd", {
      desc = "Update fex directory buffers on read (:e).",
      group = H.augroup,
      buffer = e.buf,
      callback = function()
        H.dir_get_children(e.buf)
        H.dir_set_lines(e.buf)
        H.dir_set_marks(e.buf)
      end,
    })

    vim.bo[e.buf].bufhidden = "hide"
    vim.bo[e.buf].swapfile = false
    vim.bo[e.buf].filetype = "fex"
  end,
})

--- The function used to filter children that get displayed in fex buffers.
--- Should return true if the child should be displayed.
--- @param child FexChild The child that might need to be included.
--- @return boolean include
function M.filter(child)
  return not child.name:match("^%.")
end

--- The function used to sort children that get displayed in fex buffers.
--- Return true if first should come before second.
--- @param first FexChild The candidate for first in the list.
--- @param second FexChild The candidate for second in the list.
--- @return boolean correct
function M.sort(first, second)
  if first.type == "directory" and second.type ~= "directory" then
    return true
  elseif first.type ~= "directory" and second.type == "directory" then
    return false
  end
  return first.name < second.name
end

return M
