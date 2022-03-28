local M = {}

local levels = vim.log.levels

-- vim.notify wrappers
M.notify = {}
M.notify.info = function(message)
    vim.notify(message, levels.INFO, { title = "habitats.nvim" })
end

M.notify.warn = function(message)
    vim.notify(message, levels.WARN, { title = "habitats.nvim" })
end

M.notify.err = function(message)
    vim.notify(message, levels.ERROR, { title = "habitats.nvim" })
end

return M
