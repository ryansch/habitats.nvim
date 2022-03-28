local telescope = require("telescope")
local main = require("telescope._extensions.habitats.main")

return telescope.register_extension{
  setup = main.setup,
  exports = main.exports(),
}
