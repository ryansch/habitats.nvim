local M = {}

local Path = require("plenary.path")
local workspaces = require("workspaces")
local lspconfig = require("lspconfig")
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

  -- Force normal mode in new workspace.
  -- Recent telescope changes seem to keep insert mode at times.
  vim.schedule(function()
    local mode = vim.fn.mode()
    if mode ~= "n" then
      vim.api.nvim_input "<ESC>"
    end
  end)
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

local function set_defaults()
  if vim.api.nvim_get_option("sessionoptions") == "blank,buffers,curdir,folds,help,tabpages,winsize" then
    vim.api.nvim_set_option("sessionoptions", "curdir,folds,help,tabpages,winsize")
  end
end

function M.setup(opts)
  config = vim.tbl_deep_extend('force', config, opts or {})
  config.path = Path:new(config.path)
  config.habitats_path = config.path:joinpath("habitats")
  config.sessions_path = config.path:joinpath("sessions")

  init_files()

  set_defaults()

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
            if vim.bo[bufnr].modified then
              _util.notify.warn("Save your changes first!")
              return false
            end

            if vim.bo[bufnr].filetype == "toggleterm" then
              _util.notify.warn("One or more open terminals found!")
              return false
            end
          end

          logger.debug("Stopping lsp clients")
          for _, name in ipairs(lspconfig.util.available_servers()) do
            local server_config = lspconfig[name]

            if server_config.manager then
              for _, client in ipairs(server_config.manager.clients()) do
                logger.debug("Stopping client", client.name)
                client.stop(true)
              end
            end
          end

          for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_valid(bufnr) then
              vim.api.nvim_buf_delete(bufnr, {})
            end
          end
        end,
      },
      open = vim.tbl_flatten{
        function(name)
          logger.debug("habitats.open")

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
