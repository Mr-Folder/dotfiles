return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { 
      {
        "nvim-telescope/telescope-live-grep-args.nvim" ,
        -- This will not install any breaking changes.
        -- For major updates, this must be adjusted manually.
        version = "^1.0.0",
      },
    },
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
