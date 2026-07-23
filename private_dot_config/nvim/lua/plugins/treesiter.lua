return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- enabled = false,
    opts = {
      ensure_installed = {
        "bash",
        "caddy",
        "lua",
        "yaml",
        "hcl",
        "terraform",
        "html",
        "json",
        "helm",
        "gotmpl",
        "go",
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
