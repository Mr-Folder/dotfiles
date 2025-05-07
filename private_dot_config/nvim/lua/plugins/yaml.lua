-- plugins/yaml.lua
return {
  "cuducos/yaml.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-telescope/telescope.nvim", -- optional
  },
  config = function()
    require("yaml_nvim").setup()
  end,
}
