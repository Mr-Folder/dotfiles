return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "yaml",
        "hcl",
        "terraform",
      },
      highlight = {
        enable = true,
      },
      indent = {
        enable = true,
        disable = { "yaml" }, -- Disable YAML indentation
      },
    },
  },
}
