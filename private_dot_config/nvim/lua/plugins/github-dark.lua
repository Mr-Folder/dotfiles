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
        red = "#F47067",
        orange = "#E3B341",
        textwhite = "#C9D1D9",
        fullwhite = "#E6EDF3",
        bluelight = "#96D0FF",
        green = "#8DDB8C",
        bluedark = "#6CB6FF",
        darkgrey = "#8B949E", -- slightly dimmer comment
        purple = "#C77DFF",
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
          operator = palettes.all.red, -- Operators (like '=')
          string = palettes.all.bluedark, -- Strings ("Creating endpoint")
          comment = palettes.all.darkgrey,
          number = palettes.all.bluelight, -- Numbers
          type = "#E5C07B", -- Types
        },
        -- Render Markdown backgrounds (non-transparent)
        markdown_code_bg = "#21262d",
        markdown_code_inline_bg = "#2d333b",
      },
    }

    -- Assign treesitter type to specs, use :TSInspect
    local groups = {
      all = {

        -- Fyler (match Neo-tree-ish colors)
        FylerFSDirectoryName = { fg = palettes.all.fullwhite }, -- or bluelight / textwhite
        FylerFSDirectoryIcon = { fg = palettes.all.fullwhite },

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
        ["@variable.member"] = { fg = palettes.all.purple },
        ["@function"] = { fg = palettes.all.purple },
        ["@type"] = { fg = palettes.all.purple },

        -- LUA
        ["@operator.lua"] = { fg = specs.all.syntax.operator },
        ["@property.lua"] = { fg = specs.all.syntax.variable },
        ["@markup.raw.block.markdown"] = { bg = specs.all.markdown_code_bg },
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
