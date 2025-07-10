return {
  "projekt0n/github-nvim-theme",
  lazy = false,
  priority = 1000,
  config = function()
    local options = {
      transparent = true,
      modules = {
        treesitter = {
          enable = true,
        },
      },
    }

    -- Palette table
    local palettes = {
      all = {
        red = "#FF7B72",
        purple = "#DCBDFB",
        orange = "#FFA657",
        textwhite = "#C9D1D9",
        bluelight = "#96D0FF",
        -- pink = "#F692CE",
        green = "#8DDB8C",
        bluedark = "#6CB6FF",
        darkgrey = "#A9A9A9",
      },
    }

    -- Spec table
    local specs = {
      all = {
        syntax = {
          -- Your existing specific syntax overrides with hex codes
          tag = "#ff9492",
          field = "#dbb7ff",
          builtin2 = "white",
          bg1 = "white",

          -- Direct Hex Codes for common Treesitter categories (these are your "source of truth")
          func = palettes.all.red, -- Functions/commands (like 'echo', 'az')
          variable = palettes.all.textwhite, -- Variables (like '$rg')
          parameter = palettes.all.orange, -- Parameters/Arguments (like '-g')
          keyword = palettes.all.red, -- Keywords (like 'if', 'for', 'while') - keeping your specific color
          operator = palettes.all.textwhite, -- Operators (like '=')
          string = palettes.all.bluedark, -- Strings ("Creating endpoint")
          comment = palettes.all.darkgrey,
          number = palettes.all.bluelight, -- Numbers
          type = "#E5C07B", -- Types
        },
      },
    }

    -- Assign treesitter type to specs, use :TSInspect
    local groups = {
      all = {
        -- ["@function.call.bash"] = { fg = specs.all.syntax.func },
        -- ["@function.builtin.bash"] = { fg = specs.all.syntax.func },
        -- ["@operator.bash"] = { fg = specs.all.operator },
        -- ["@variable.bash"] = { fg = specs.all.syntax.variable },
        ["@number.bash"] = { fg = specs.all.syntax.number },
        ["@boolean.bash"] = { fg = specs.all.syntax.number },
        ["@variable.parameter.bash"] = { fg = specs.all.syntax.parameter },
        -- ["@string.bash"] = { fg = specs.all.syntax.string },
        -- ["@comment.bash"] = { fg = specs.all.syntax.comment },
        -- ["@keyword.bash"] = { fg = specs.all.syntax.keyword },

        -- LUA
        ["@operator.lua"] = { fg = specs.all.syntax.operator },
        ["@property.lua"] = { fg = specs.all.syntax.variable },
      },
    }

    require("github-theme").setup({
      palettes = palettes,
      specs = specs,
      options = options,
      groups = groups,
    })

    vim.cmd("colorscheme github_dark_default")
  end,
}
