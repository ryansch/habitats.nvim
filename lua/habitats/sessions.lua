local M = {}

local Path = require("plenary.path")
local sessions = require("sessions")
local logger = require("habitats.logger")
local _util = require("habitats.util")

local config = {
  session_path = Path:new(vim.fn.stdpath("data"), "habitats.nvim", "sessions"),
}

---Load an existing session file and begin autosaving
---@param name string
function M.load(name)
  local path = config.session_path:joinpath(name).filename

  sessions.load(path, { silent = true })
  sessions.save(path, { autosave = true })
end

---Save the current session and stop autosaving
function M.save_and_stop()
  sessions.stop_autosave{ save = true }
end

---Rename a session
---@param name string
---@param new_name string
---@param current_session_name string|nil
---@return boolean
function M.rename(name, new_name, current_session_name)
  if name == current_session_name then
    sessions.stop_autosave{ save = true }
  end

  local path = config.session_path:joinpath(name)

  if not path:exists() then
    -- The session file doesn't exist so we can claim success!
    return true
  end

  local new_path = config.session_path:joinpath(new_name)
  local result = path:copy{ destination = new_path, override = false }
  logger.debug("result", result)
  if not result[new_path] then
    _util.notify.warn(string.format("Unable to copy to %s", new_path.filename))
    return false
  end

  path:rm()

  if name == current_session_name then
    sessions.save(new_path.filename, { autosave = true })
  end

  return true
end

---Delete a session
---@param name string
---@param current_session_name string|nil
function M.delete(name, current_session_name)
  if name == current_session_name then
    sessions.stop_autosave{ save = true }
  end

  local path = config.session_path:joinpath(name)
  path:rm()
end

---Setup habitat sessions
---@param opts table
function M.setup(opts)
  config = vim.tbl_deep_extend('force', config, opts or {})
  config.session_path = Path:new(config.session_path)

  require("sessions").setup{
    -- events = { "BufEnter" },
  }

  return M
end

return M
