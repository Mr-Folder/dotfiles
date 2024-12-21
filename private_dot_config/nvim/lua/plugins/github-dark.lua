return {
  "projekt0n/github-nvim-theme",
  lazy = false, -- make sure we load this during startup if it is your main colorscheme
  priority = 1000, -- make sure to load this before all the other start plugins
  config = function()
    local options = {
      transparent = true,
    }
    local palettes = {
      all = {
        yellow = "#000000",
      },
    }
    local specs = {
      all = {
        syntax = {
          tag = "#ff9492",
          field = "#dbb7ff", -- Field
          builtin2 = "white", -- Builtin const
          bg1 = "white",
        },
      },
    }
    require("github-theme").setup({ palettes = palettes, specs = specs, options = options })

    vim.cmd("colorscheme github_dark_default")
  end,
}
