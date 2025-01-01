return {
  {
    "nvim-telescope/telescope.nvim",
    opts = {},
    config = function()
      local actions = require("telescope.actions")
      require("telescope").setup({
        pickers = {
          find_files = {
            hidden = true,
          },
        },
        defaults = {
          mappings = {
            i = {
              ["<esc>"] = actions.close,
            },
          },
        },
        extensions = {
          frecency = {
            show_unindexed = false,
            workspaces = {
              ["CWD"] = vim.fn.getcwd(),
            },
          },
        },
      })
    end,
  },
}
