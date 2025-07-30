return {
  "A7Lavinraj/fyler.nvim",
  enabled = false,
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    {
      "<leader>e",
      function()
        -- Check if any Fyler window is open
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          local filetype = vim.api.nvim_buf_get_option(buf, "filetype")
          if filetype == "fyler" then
            -- Close Fyler window if found
            vim.api.nvim_win_close(win, false)
            return
          end
        end
        -- Open Fyler if not found
        vim.cmd("Fyler kind=split:left")
      end,
      desc = "Toggle Fyler (File Explorer)",
    },
  },
  opts = {
    -- Allow user to confirm simple edits
    auto_confirm_simple_edits = true,

    -- Set as default explorer to replace netrw
    default_explorer = true,

    -- Close fyler window when opening a file
    close_on_select = true,

    -- Use default icon provider for now to get proper folder behavior
    icon_provider = "nvim-web-devicons",

    -- Show git status
    git_status = true,

    -- Configure indentation markers
    indentscope = {
      enabled = true,
      group = "FylerIndentMarker",
      marker = "│",
    },

    -- Custom highlight function to make folder icons white
    on_highlights = function(hl_groups, palette)
      -- Make directories white instead of blue
      hl_groups.FylerFSDirectory = { fg = palette.white }
      -- Override the FylerBlue highlight used by directory icons
      hl_groups.FylerBlue = { fg = palette.white }
    end,

    -- Configure views - set explorer to open as left split by default
    views = {
      confirm = {
        width = 0.8,
        height = 0.8,
        kind = "float",
        border = "single",
        buf_opts = {
          buflisted = false,
          modifiable = false,
        },
        win_opts = {
          winhighlight = "Normal:Normal,FloatBorder:FloatBorder,FloatTitle:FloatTitle",
          wrap = false,
        },
      },
      explorer = {
        width = 0.25, -- 25% of screen width for left pane
        height = 1.0,
        kind = "split:left", -- Open as left split like nvim-tree
        border = "none",
        buf_opts = {
          buflisted = false,
          buftype = "acwrite",
          filetype = "fyler",
          syntax = "fyler",
        },
        win_opts = {
          concealcursor = "nvic",
          conceallevel = 3,
          cursorline = true,
          number = false, -- No line numbers in file explorer
          relativenumber = false,
          winhighlight = "Normal:Normal",
          wrap = false,
        },
      },
    },

    -- Key mappings
    mappings = {
      confirm = {
        n = {
          ["y"] = "Confirm",
          ["n"] = "Discard",
        },
      },
      explorer = {
        n = {
          ["q"] = "CloseView",
          ["<CR>"] = "Select",
          ["<Esc>"] = "CloseView",
        },
      },
    },
  },
}
