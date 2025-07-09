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
        "helm",
      },
      highlight = {
        enable = true,
        -- disable = { "bash" },
      },
      indent = {
        disable = { "yaml" }, -- Disable YAML indentation
      },
    },
  },
}
