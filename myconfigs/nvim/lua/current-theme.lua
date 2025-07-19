-- Set colorscheme with error handling
local ok, _ = pcall(vim.cmd, "colorscheme rose-pine-moon")
if not ok then
    -- Fallback to default colorscheme if rose-pine-moon is not available
    vim.cmd("colorscheme default")
    vim.notify("Warning: rose-pine-moon colorscheme not found, using default")
end
