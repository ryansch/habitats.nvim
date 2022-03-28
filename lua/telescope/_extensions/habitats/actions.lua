local M = {}

local actions = require("telescope.actions")
local actions_state = require("telescope.actions.state")
local transform_mod = require('telescope.actions.mt').transform_mod

local habitats = require("habitats")

-- Extracts project path from current buffer selection
function M.get_selected_habitat()
  return actions_state.get_selected_entry().value
end

function M.open_habitat(prompt_bufnr)
  local habitat = M.get_selected_habitat()
  actions.close(prompt_bufnr)

  habitats.open(habitat.name)
end

function M.add_habitat(prompt_bufnr)
  actions._close(prompt_bufnr, true)

  local folder_browser = require("telescope._extensions.habitats.folder_browser")
  folder_browser{
    cwd = "~/dev",
  }
end

function M.delete_habitat()
  local habitat = M.get_selected_habitat()

  habitats.delete(habitat.name)
end

function M.rename_habitat()
  local habitat = M.get_selected_habitat()

  vim.ui.input(
    {
      prompt = "New name: ",
    },
    function(new_name)
      if not new_name then return end
      if new_name == "" then
        print "Please enter valid name!"
        return
      end
      if new_name == habitat.name then
        -- no op
        return
      end

      habitats.rename(habitat.name, new_name)
    end
  )
end

return transform_mod(M)
