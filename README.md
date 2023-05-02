# habitats.nvim

"Habitats" for your neovim projects

## 📦 Installation

Install the plugin with your preferred package manager:

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
  {
    "ryansch/habitats.nvim",

    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-file-browser.nvim",
      "natecraddock/sessions.nvim",
      "natecraddock/workspaces.nvim",
    },

    event = "VeryLazy",

    keys = {
      {
        "<leader>oh",
        function()
          require("telescope").extensions.habitats.habitats()
        end,
        desc = "Habitats",
      },
    },

    config = function(_, opts)
      require("habitats").setup(opts)
      require("telescope").load_extension("habitats")
    end,
  },
```

## ⚙️ Configuration

**habitats.nvim** comes with the following defaults:

```lua
  {
    "ryansch/habitats.nvim",

    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-file-browser.nvim",
      "natecraddock/sessions.nvim",
      "natecraddock/workspaces.nvim",
    },

    event = "VeryLazy",

    keys = {
      {
        "<leader>oh",
        function()
          require("telescope").extensions.habitats.habitats()
        end,
        desc = "Habitats",
      },
    },

    opts = {
      path = Path:new(vim.fn.stdpath("data"), "habitats.nvim"),
      global_cd = true,
      sort = true,
      notify_info = true,
      log_level = "info",
      sessionoptions = "curdir,folds,help,tabpages,winsize",

      hooks = {
        add = {},
        remove = {},
        rename = {},
        open_pre = {},
        open = {},
      },
    },

    config = function(_, opts)
      require("habitats").setup(opts)
      require("telescope").load_extension("habitats")
    end,
  },
```

Additionally you can add it to your dashboard like so:

```lua
  {
    "goolord/alpha-nvim",
    opts = function(_, dashboard)
      local button = dashboard.button("h", " " .. " Habitats", ":Telescope habitats <CR>")
      button.opts.hl = "AlphaButtons"
      button.opts.hl_shortcut = "AlphaShortcut"
      table.insert(dashboard.section.buttons.val, 4, button)
    end,
  },
```
