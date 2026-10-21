-- plugins/nix.lua
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "nix" } },
  },
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "nixfmt" } },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- mason builds nil with cargo, which isn't installed; provide nil on PATH instead
        nil_ls = { mason = false },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = { formatters_by_ft = { nix = { "nixfmt" } } },
  },
}
