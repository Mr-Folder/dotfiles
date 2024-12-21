return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- enabled = false,
    opts = {
      ensure_installed = {
        "yaml",
        "hcl",
        "terraform",
        "html",
        "json",
      },
      highlight = {
        enable = true,
      },
      indent = {
        disable = { "yaml" }, -- Disable YAML indentation
      },
    },
  },
}
