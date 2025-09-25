return {
  "folke/trouble.nvim",
  enabled = true,
  opts = {
    -- Fix the terraform-ls freeze because of too large uint32 coming from not closing a bracket.
    auto_refresh = false,
  },
}
