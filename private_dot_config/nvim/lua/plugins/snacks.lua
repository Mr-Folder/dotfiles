return {
  "folke/snacks.nvim",
  opts = {
    -- enable whatever modules you like…
    dashboard = { enabled = true },
    -- …then configure the terminal:
    terminal = {
      win = {
        position = "float",
        border = "rounded",
        width = 0.8,
        height = 0.8,
      },
    },
  },
}
