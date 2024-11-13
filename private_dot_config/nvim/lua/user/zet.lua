local M = {}

function M.create_md_file()
  vim.ui.input({ prompt = "Enter filename" }, function(input)
    if input == nil or input == "" then
      return
    end
    -- Properly quote the input to handle spaces and special characters
    local cmd = string.format("%s %q", os.getenv("HOME") .. "/.local/bin/zet", input)
    os.execute(cmd)
  end)
end

return M
