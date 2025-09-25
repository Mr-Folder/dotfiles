return {

  "mason-org/mason.nvim",
  version = "^2.0.0",
  cmd = "Mason",
  keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
  build = ":MasonUpdate",
  opts_extend = { "ensure_installed" },
  opts = {
    ensure_installed = {
      "yaml-language-server",
      "terraform-ls",
    },
  },
}
