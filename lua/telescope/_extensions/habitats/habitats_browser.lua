local picker_m = {}

local actions = require("telescope.actions")
local actions_state = require("telescope.actions.state")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values

local _actions = require("telescope._extensions.habitats.actions")
local _finders = require("telescope._extensions.habitats.finders")
local habitats = require("habitats")

function picker_m.habitats_browser(opts)
  opts = opts or {}

  -- default to dropdown theme
  if not opts.theme then
    opts = require("telescope.themes").get_dropdown(opts)
  end

  pickers.new(opts, {
    prompt_title = "Select a habitat",
    results_title = "Habitats",
    finder = _finders.habitat_finder(opts, habitats.get()),
    sorter = conf.file_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      local refresh_projects = function()
        local picker = actions_state.get_current_picker(prompt_bufnr)
        local finder = _finders.habitat_finder(opts, habitats.get())
        picker:refresh(finder, { reset_prompt = true })

        -- force insert mode
        local mode = vim.fn.mode()
        local keys = mode ~= "n" and "<ESC>A" or "A"
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", true)
      end

      _actions.delete_habitat:enhance({ post = refresh_projects })
      _actions.rename_habitat:enhance({ post = refresh_projects })

      map("n", "o", _actions.open_habitat)
      map("n", "a", _actions.add_habitat)
      map("n", "d", _actions.delete_habitat)
      map("n", "r", _actions.rename_habitat)

      actions.select_default:replace(function()
        _actions.open_habitat(prompt_bufnr)
      end)
      return true
    end
  }):find()
end


return picker_m.habitats_browser
