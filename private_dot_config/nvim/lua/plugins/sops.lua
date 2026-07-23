return {
  "trixnz/sops.nvim",
  lazy = false,
  config = function()
    -- Upstream only knows yaml/json markers, looked up by filetype. A `.env`
    -- file is filetype `sh` and its marker is `sops_mac=ENC[`, so wrap the
    -- detector to cover dotenv before registering the autocmds.
    local util = require("sops.util")
    local upstream_is_sops_encrypted = util.is_sops_encrypted

    util.is_sops_encrypted = function(bufnr)
      local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
      if filetype == "sh" or filetype == "dotenv" then
        for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
          if string.find(line, "sops_mac=ENC[", nil, true) then
            return true
          end
        end

        return false
      end

      return upstream_is_sops_encrypted(bufnr)
    end

    require("sops").setup({
      supported_file_formats = { "*.env" },
    })
  end,
}
