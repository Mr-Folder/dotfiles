-- In your plugin configuration file (e.g., ~/.config/nvim/lua/plugins/dressing.lua)
return {
  "stevearc/dressing.nvim",
  event = "VeryLazy",
  config = function()
    require("dressing").setup({
      input = {
        -- Other configurations...

        -- Use get_config to customize per prompt
        get_config = function(opts)
          if opts.prompt == "Enter filename" then
            return {
              relative = "editor",
              style = "minimal",
              width = 0.3,
              override = function(conf)
                conf.anchor = "NW"
                conf.row = 3
                conf.col = (vim.o.columns - conf.width) / 2
                return conf
              end,
            }
          end
        end,
      },
      select = {
        -- Select configurations...
      },
    })
  end,
}
