return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {
    code = {
      style = "full",
      position = "left",
      language_pad = 0,
      disable_background = { "diff" },
      width = "full",
      left_pad = 0,
      right_pad = 0,
      min_width = 0,
      border = "thin",
      above = "▄",
      below = "▀",
      highlight = "RenderMarkdownCode",
      highlight_inline = "RenderMarkdownCodeInline",
    },
  },
}
