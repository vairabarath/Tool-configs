-- Custom commands for language management

local language_manager = require("Settings.languages")

-- Command to show available languages
vim.api.nvim_create_user_command("LanguageStatus", function()
    local languages = language_manager.get_languages()
    local status_lines = {
        "=== Language Configuration Status ===",
        "",
    }
    
    for _, lang in ipairs(languages) do
        table.insert(status_lines, "✓ " .. lang:upper() .. " - Configured and loaded")
    end
    
    table.insert(status_lines, "")
    table.insert(status_lines, "Total languages: " .. #languages)
    
    -- Create a temporary buffer to display the status
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, status_lines)
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
    vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
    
    -- Open in a floating window
    local width = 50
    local height = #status_lines + 2
    local row = math.ceil((vim.o.lines - height) / 2)
    local col = math.ceil((vim.o.columns - width) / 2)
    
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded",
        title = " Language Status ",
        title_pos = "center",
    })
    
    -- Set buffer-local keymap to close with 'q' or 'Esc'
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true })
    vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf, silent = true })
end, {
    desc = "Show language configuration status"
})

-- Command to setup a specific language
vim.api.nvim_create_user_command("LanguageSetup", function(opts)
    local lang = opts.args
    if lang == "" then
        vim.notify("Please specify a language name", vim.log.levels.ERROR)
        return
    end
    
    language_manager.setup_language(lang)
    vim.notify("Attempted to setup language: " .. lang, vim.log.levels.INFO)
end, {
    desc = "Setup a specific language configuration",
    nargs = 1,
    complete = function()
        return language_manager.get_languages()
    end,
})

-- Command to reload all language configurations  
vim.api.nvim_create_user_command("LanguageReload", function()
    vim.notify("Reloading all language configurations...", vim.log.levels.INFO)
    language_manager.setup_all()
    language_manager.setup_plugin_dependent_configs()
    vim.notify("Language configurations reloaded!", vim.log.levels.INFO)
end, {
    desc = "Reload all language configurations"
})

-- Function to get language-specific keymaps
local function get_language_keymaps()
    local current_ft = vim.bo.filetype
    local language_keymaps = {}
    
    -- Language mappings
    local lang_map = {
        go = "Go",
        rust = "Rust", 
        javascript = "Web",
        typescript = "Web",
        javascriptreact = "Web",
        typescriptreact = "Web",
        html = "Web",
        css = "Web",
        svelte = "Web",
        json = "Web",
    }
    
    local current_lang = lang_map[current_ft]
    if not current_lang then
        return {}
    end
    
    -- Define language-specific keymaps
    local keymaps = {
        Go = {
            { key = "<leader>go", desc = "Organize Go imports", mode = "n" },
            { key = "<leader>gi", desc = "Add missing Go imports", mode = "n" },
            { key = "<leader>gf", desc = "Format Go file", mode = "n" },
            { key = "<leader>gb", desc = "Go build", mode = "n" },
            { key = "<leader>gt", desc = "Go test", mode = "n" },
            { key = "<leader>gr", desc = "Go run current file", mode = "n" },
            { key = "<leader>gm", desc = "Go mod tidy", mode = "n" },
            { key = "<leader>db", desc = "Toggle breakpoint", mode = "n" },
            { key = "<leader>dc", desc = "Continue debugging", mode = "n" },
            { key = "<leader>do", desc = "Step over", mode = "n" },
            { key = "<leader>di", desc = "Step into", mode = "n" },
            { key = "<leader>dq", desc = "Terminate debugging", mode = "n" },
        },
        Rust = {
            { key = "<leader>rr", desc = "Rust runnables", mode = "n" },
            { key = "<leader>rt", desc = "Run tests", mode = "n" },
            { key = "<leader>rc", desc = "Open Cargo.toml", mode = "n" },
            { key = "<leader>rp", desc = "Go to parent module", mode = "n" },
            { key = "<leader>rd", desc = "Rust debuggables", mode = "n" },
            { key = "<leader>rh", desc = "Rust hover actions", mode = "n" },
            { key = "<leader>re", desc = "Expand macro", mode = "n" },
            { key = "<leader>cb", desc = "Cargo build", mode = "n" },
            { key = "<leader>cc", desc = "Cargo check", mode = "n" },
            { key = "<leader>ct", desc = "Cargo test", mode = "n" },
            { key = "<leader>cr", desc = "Cargo run", mode = "n" },
            { key = "<leader>rih", desc = "Toggle inlay hints", mode = "n" },
            { key = "<leader>rid", desc = "Toggle virtual text diagnostics", mode = "n" },
        },
        Web = {
            { key = "<leader>co", desc = "Organize imports (TypeScript)", mode = "n" },
            { key = "<leader>cR", desc = "Rename file", mode = "n" },
            { key = "<leader>ci", desc = "Add missing imports", mode = "n" },
            { key = "<leader>cu", desc = "Remove unused imports", mode = "n" },
            { key = "<leader>cf", desc = "Fix all issues", mode = "n" },
            { key = "<leader>ni", desc = "npm install", mode = "n" },
            { key = "<leader>ns", desc = "npm start", mode = "n" },
            { key = "<leader>nb", desc = "npm build", mode = "n" },
            { key = "<leader>nt", desc = "npm test", mode = "n" },
        },
    }
    
    return keymaps[current_lang] or {}
end

-- Command to show language-specific keymaps
vim.api.nvim_create_user_command("LanguageKeymaps", function()
    local keymaps = get_language_keymaps()
    local current_ft = vim.bo.filetype
    
    if #keymaps == 0 then
        vim.notify("No language-specific keymaps for filetype: " .. current_ft, vim.log.levels.INFO)
        return
    end
    
    -- Format keymaps for display
    local keymap_lines = { "=== Language-Specific Keymaps ===" }
    table.insert(keymap_lines, "")
    table.insert(keymap_lines, "Language: " .. current_ft:upper())
    table.insert(keymap_lines, "")
    
    for _, keymap in ipairs(keymaps) do
        table.insert(keymap_lines, string.format("%-20s %s", keymap.key, keymap.desc))
    end
    
    -- Create a temporary buffer to display the keymaps
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, keymap_lines)
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
    vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
    
    -- Open in a floating window
    local width = math.max(60, #keymap_lines[1] + 10)
    local height = #keymap_lines + 4
    local row = math.ceil((vim.o.lines - height) / 2)
    local col = math.ceil((vim.o.columns - width) / 2)
    
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded",
        title = " Language Keymaps ",
        title_pos = "center",
    })
    
    -- Set buffer-local keymap to close with 'q' or 'Esc'
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true })
    vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf, silent = true })
end, {
    desc = "Show language-specific keymaps for current filetype"
})

-- Global keymap for language keymaps picker
vim.keymap.set("n", "<leader>pl", function()
    vim.cmd("LanguageKeymaps")
end, { desc = "Show language-specific keymaps", noremap = true, silent = true })
