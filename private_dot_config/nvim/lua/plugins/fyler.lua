return {
  "A7Lavinraj/fyler.nvim",
  branch = "stable",
  lazy = false,
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    integrations = { icon = "nvim_web_devicons" },

    views = {
      finder = {
        columns_order = { "git", "diagnostic" },

        columns = {
          git = {
            enabled = false,
          },
        },

        win = {
          kind = "split_left_most",
          kinds = {
            split_left_most = { width = "20%", win_opts = { winfixwidth = true } },
          },
          win_opts = {
            cursorline = true,
            signcolumn = "yes",
          },
        },

        icon = {
          directory_collapsed = "",
          directory_expanded = "",
          directory_empty = "",
        },
      },
    },
  },
}
