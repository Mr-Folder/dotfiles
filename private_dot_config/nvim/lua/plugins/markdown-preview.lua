return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  ft = { "markdown" },
  build = ":call mkdp#util#install()",
  keys = {
    { "<leader>mp", "<cmd>MarkdownPreview<cr>", desc = "Markdown Preview" },
  },
}
