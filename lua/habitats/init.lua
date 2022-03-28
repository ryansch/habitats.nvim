local M = {}

local Path = require("plenary.path")
local workspaces = require("workspaces")
local _sessions = require("habitats.sessions")
local _util = require("habitats.util")

local config = {
  path = Path:new(vim.fn.stdpath("data"), "habitats.nvim"),
  global_cd = true,
  sort = true,
  notify_info = true,

  hooks = {
    add = {},
    remove = {},
    open_pre = {},
    open = {},
  }
}

function M.add(name, path)
  if not name or not path then
    _util.notify.err("Missing name or path!")
  end

  workspaces.add_swap(name, path)
end

function M.delete(name)
  -- TODO: remove session data
  workspaces.remove(name)
end

function M.rename(name, new_name)
  -- TODO
  _util.notify.warn("Not implemented!")

  -- if config.notify_info then
  --   _util.notify.info(string.format("habitat [%s -> %s] renamed", name, new_name))
  -- end
end

function M.get()
  return workspaces.get()
end

function M.list()
  return workspaces.list()
end

function M.open(name)
  workspaces.open(name)
end

local function init_files()
  if not config.path:exists() then
    config.path:mkdir()
  end

  if not config.habitats_path:exists() then
    config.habitats_path:touch()
  end

  if not config.sessions_path:exists() then
    config.sessions_path:mkdir()
  end
end

function M.setup(opts)
  config = vim.tbl_deep_extend('force', config, opts or {})
  config.path = Path:new(config.path)
  config.habitats_path = config.path:joinpath("habitats")
  config.sessions_path = config.path:joinpath("sessions")

  init_files()

  workspaces.setup{
    path = config.habitats_path.filename,
    global_cd = config.global_cd,
    sort = config.sort,
    notify_info = false,
    hooks = {
      add = vim.tbl_flatten{
        config.hooks.add,
        function(name, path)
          if config.notify_info then
            _util.notify.info(string.format("habitat [%s -> %s] added", name, path))
          end
        end
      },
      remove = vim.tbl_flatten{
        config.hooks.remove,
        function(name, path)
          if config.notify_info then
            _util.notify.info(string.format("habitat [%s -> %s] deleted", name, path))
          end
        end
      },
      open_pre = vim.tbl_flatten{
        function()
          logger.debug("habitats.open_pre")
        end,
        config.hooks.open_pre,
        function()
          _sessions.save_and_stop()

          for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
            -- TODO: Deal with terminal windows
            -- TODO: Deal with modified buffers
            vim.cmd(string.format("bwipeout %d", bufnr))
          end
        end,
      },
      open = vim.tbl_flatten{
        function(name)
          logger.debug("habitats.open")
          vim.cmd("Startify")

          require("titan.lsp").reload_custom_commands()
          _sessions.load(name)

          -- Set kitty tab name
          -- local result = vim.fn.system({"kitty", "@", "set-tab-title", "-m", "recent:0", name})
          -- print(result)
        end,
        config.hooks.open,
      },
    }
  }

  _sessions.setup{
    session_path = config.sessions_path.filename,
  }

  require("telescope").load_extension("habitats")
end

return M
