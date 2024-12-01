return {
  "projekt0n/github-nvim-theme",
  lazy = false, -- make sure we load this during startup if it is your main colorscheme
  priority = 1000, -- make sure to load this before all the other start plugins
  config = function()
    local palettes = {
      github_dark_high_contrast = {
        yellow = "#000000",
      },
    }
    local specs = {
      github_dark_high_contrast = {
        syntax = {
          tag = "#ff9492",
          field = "#dbb7ff", -- Field
          builtin2 = "white", -- Builtin const
        },
      },
    }
    require("github-theme").setup({ palettes = palettes, specs = specs })

    vim.cmd("colorscheme github_dark_high_contrast")
  end,
}
