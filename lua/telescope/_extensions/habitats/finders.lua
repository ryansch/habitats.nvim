local M = {}

local finders = require("telescope.finders")
local Path = require('plenary.path')
local strings = require("plenary.strings")
local entry_display = require("telescope.pickers.entry_display")
local async_oneshot_finder = require("telescope.finders.async_oneshot_finder")

local fb_make_entry = require("telescope._extensions.file_browser.make_entry")

function M.habitat_finder(opts, habitats)
  opts = opts or {}
  local display_type = opts.display_type
  local widths = {
    name = 0,
    display_path = 0,
  }

  -- Loop over all of the habitats and find the maximum length of
  -- each of the keys
  for _, habitat in ipairs(habitats) do
    if display_type == 'full' then
      habitat.display_path = '[' .. habitat.path .. ']'
    else
      habitat.display_path = ''
    end
    local habitat_path_exists = Path:new(habitat.path):exists()
    if not habitat_path_exists then
      habitat.name = habitat.name .. " [deleted]"
    end
    for key, value in pairs(widths) do
      widths[key] = math.max(value, strings.strdisplaywidth(habitat[key] or ''))
    end
  end

  local displayer = entry_display.create {
    separator = " ",
    items = {
      { width = widths.name },
      { width = widths.display_path },
    }
  }
  local make_display = function(habitat)
    return displayer {
      { habitat.value.name },
      { habitat.value.display_path }
    }
  end

  return finders.new_table {
    results = habitats,
    entry_maker = function(habitat)
      return {
        value = habitat,
        ordinal = habitat.name,
        display = make_display,
      }
    end,
  }
end

local function _folder_finder(opts)
  -- returns copy with properly set cwd for entry maker
  local cwd = opts.cwd_to_path and opts.path or opts.cwd
  local entry_maker = opts.entry_maker { cwd = cwd }

  local args = { "-t", "d", "-a", "--exact-depth", "1" }
  if opts.hidden then
    table.insert(args, "-H")
  end
  if opts.respect_gitignore == false then
    table.insert(args, "--no-ignore-vcs")
  end

  return async_oneshot_finder {
    fn_command = function()
      return { command = "zsh -ic fd", args = args }
    end,
    entry_maker = entry_maker,
    results = { entry_maker(cwd) },
    cwd = cwd,
  }
end

function M.folder_finder(opts)
  opts = opts or {}
  opts.entry_cache = {}

  return setmetatable({
    cwd = opts.cwd,
    _folder_finder = opts.folder_finder or _folder_finder,
    entry_maker = function(local_opts)
      return fb_make_entry(vim.tbl_extend("force", opts, local_opts))
    end,
    close = function(self)
      if self._finder then
        self._finder:close()
      end
      self._finder = nil
    end,
  }, {
    __call = function(self, ...)
      if not self._finder then
        self._finder = self:_folder_finder()
      end
      self._finder(...)
    end,
    __index = function(self, k)
      if rawget(self, "_finder") then
        local finder_val = self._finder[k]
        if finder_val ~= nil then
          return finder_val
        end
      end
    end,
  })
end

return M
