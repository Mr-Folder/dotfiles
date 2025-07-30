return {
  "nvim-neo-tree/neo-tree.nvim",
  enabled = true, -- Disabled in favor of Fyler.nvim
  opts = {
    event_handlers = {
      {
        event = "neo_tree_buffer_enter",
        handler = function()
          local map = vim.keymap.set
          local api = require("neo-tree.sources.manager")

          -- Function to grep at current node
          local function grep_at_current_node()
            local state = api.get_state("filesystem")
            local node = state.tree:get_node()
            if not node then
              vim.notify("No node under cursor", vim.log.levels.WARN)
              return
            end
            local path = node.path or node.id
            require("telescope.builtin").live_grep({
              search_dirs = { path },
            })
            vim.notify("Grep at: " .. path)
          end

          -- Set keymap only in Neo-tree
          map("n", "<leader>gr", grep_at_current_node, {
            buffer = true,
            desc = "Grep at Neo-tree node",
          })
        end,
      },
    },
  },
}
