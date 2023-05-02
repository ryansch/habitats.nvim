local M = {}

-- local _actions = require("telescope._extensions.habitats.actions")
local habitats_browser = require("telescope._extensions.habitats.habitats_browser")

local config = {}

function M.setup(setup_config)
	config = vim.tbl_deep_extend("force", config, setup_config or {})
end

function M.exports()
	return {
		habitats = habitats_browser,
	}
end

return M
