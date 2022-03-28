local picker_m = {}

local actions = require("telescope.actions")
local actions_state = require("telescope.actions.state")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values

local _finders = require("telescope._extensions.habitats.finders")
local habitats = require("habitats")

function picker_m.add_habitat_with_path(prompt_bufnr)
  local selection = actions_state.get_selected_entry()
  actions.close(prompt_bufnr)
  local path = selection[1]

  vim.ui.input(
    {
      prompt = "Habitat name: ",
      default = selection.ordinal,
    },
    function(name)
      if not name then return end
      if name == "" then
        print "Please enter valid name!"
        return
      end

      habitats.add(name, path)
    end
  )

  vim.schedule(function()
    local habitats_browser = require("telescope._extensions.habitats.habitats_browser")
    habitats_browser()
  end)
end

function picker_m.cd(prompt_bufnr)
  local picker = actions_state.get_current_picker(prompt_bufnr)
  local finder = picker.finder
  local entry_path = actions_state.get_selected_entry().Path

  finder.cwd = entry_path:absolute()
  picker:refresh(finder, { reset_prompt = true })
end

function picker_m.cd_parent(prompt_bufnr)
  local picker = actions_state.get_current_picker(prompt_bufnr)
  local finder = picker.finder
  local entry_path = actions_state.get_selected_entry().Path

  finder.cwd = entry_path:parent():absolute()
  picker:refresh(finder, { reset_prompt = true })
end

function picker_m.cd_home(prompt_bufnr)
  local picker = actions_state.get_current_picker(prompt_bufnr)
  local finder = picker.finder

  finder.cwd = vim.loop.os_homedir()
  picker:refresh(finder, { reset_prompt = true })
end

function picker_m.folder_browser(opts)
  opts = opts or {}

  local cwd = vim.loop.cwd()
  opts.cwd = opts.cwd and vim.fn.expand(opts.cwd) or cwd
  opts.hide_parent_dir = vim.F.if_nil(opts.hide_parent_dir, false)

  pickers.new(opts, {
    prompt_title = "Habitat folder",
    results_title = "Results",
    finder = _finders.folder_finder(opts),
    previewer = conf.file_previewer(opts),
    sorter = conf.file_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)

      map("n", "<Right>", picker_m.cd)
      map("i", "<C-Right>", picker_m.cd)
      map("n", "l", picker_m.cd)
      map("i", "<C-l>", picker_m.cd)

      map("n", "h", picker_m.cd_home)
      map("n", "u", picker_m.cd_parent)

      actions.select_default:replace(function()
        picker_m.add_habitat_with_path(prompt_bufnr)
      end)
      return true
    end
  }):find()
end

return picker_m.folder_browser
