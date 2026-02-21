--- simirian's Neovim
--- async library

local M = {}

--- All existing async objects.
--- @type table<thread, Async>
local threads = {}

--- Represents an asynchronous thread. Functions wrapped in `Async` objects can
--- freely yield to prevent blocking, and will quickly be resumed after other
--- events are processed.
--- @class Async
M.Async = {
  --- The lua coroutine associated with the object.
  --- @type thread
  co = nil,

  --- True if the async object should not resume.
  --- @type boolean?
  shouldabort = nil,

  --- Callback for when the async function successfully returns.
  --- @type fun(out: any)?
  ondone = nil,

  --- How long to wait to resume after the wrapped function yields.
  --- @type integer
  timeout = 0,

  --- The system output object associated with this async routine for calls to
  --- `async.system()`.
  --- @type vim.SystemObj?
  system = nil,
}

--- Creates a new async routine.
--- @param fn fun(): any
--- @return Async
function M.Async.new(fn)
  local co = coroutine.create(fn)
  local self = setmetatable({ co = co }, { __index = M.Async })
  threads[co] = self
  return self
end

--- Runs the async routine.
function M.Async:run()
  if self.shouldabort then
    threads[self.co] = nil
    return
  end
  local ret = { coroutine.resume(self.co) }
  if not table.remove(ret, 1) then
    threads[self.co] = nil
    error(ret[1])
  end
  local status = coroutine.status(self.co)
  if status == "dead" then
    threads[self.co] = nil
    if self.ondone then
      self.ondone(unpack(ret))
    end
  elseif status == "suspended" then
    vim.defer_fn(function() self:run() end, self.timeout)
  end
end

--- Aborts the async routine.
function M.Async:abort()
  if self.system then
    --- @diagnostic disable-next-line: undefined-field
    self.system:kill(vim.uv.constants.SIGTERM)
  end
  self.shouldabort = true
end

--- Registers a completion callback.
--- @param cb fun(any)
function M.Async:done(cb)
  self.ondone = cb
  return self
end

--- Sets a delay for subsequent calls to the function. USE WITH CARE.
--- @param ms integer The delay time in miliseconds.
function M.Async:delay(ms)
  self.timeout = ms
  return self
end

--- If an async routine is running, then returns it. Otherwise returns nil.
--- @return Async? async The currently running async routine.
function M.running()
  return threads[coroutine.running()]
end

--- Runs a command with all callbacks wrapped as async functions. MUST be called
--- within an `Async` routine.
--- @param cmd string[] The command to execute.
--- @param opts vim.SystemOpts Options.
--- @return vim.SystemCompleted? out Command output on success, nil on failure.
function M.system(cmd, opts)
  local async = threads[coroutine.running()]
  if not async then return end
  local out
  async.system = vim.system(cmd, opts, function(o) out = o end)
  while not out do
    coroutine.yield()
  end
  return out
end

setmetatable(M, {
  __call = function (_, fn)
    return M.Async.new(fn)
  end
})

return M
