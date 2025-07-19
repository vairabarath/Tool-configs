-- Set colorscheme with error handling
local ok, _ = pcall(vim.cmd, "colorscheme rose-pine-moon")
if not ok then
    -- Fallback to default colorscheme if rose-pine-moon is not available
    vim.cmd("colorscheme default")
    vim.notify("Warning: rose-pine-moon colorscheme not found, using default")
end

-- Custom inlay hint styling for better appearance
vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = function()
        -- Set custom inlay hint colors that blend well with the theme
        vim.api.nvim_set_hl(0, "LspInlayHint", {
            fg = "#6e6a86",     -- Muted purple-gray that works with rose-pine
            bg = "NONE",        -- Transparent background
            italic = true,      -- Italic to distinguish from regular code
        })
    end,
})

-- Apply the styling immediately for the current session
vim.api.nvim_set_hl(0, "LspInlayHint", {
    fg = "#6e6a86",
    bg = "NONE",
    italic = true,
})
