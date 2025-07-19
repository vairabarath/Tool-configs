local M = {}

M.lspconfig = function()
    local ok_lsp, lspconfig = pcall(require, "lspconfig")
    local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
    
    if not ok_lsp or not ok_cmp then
        return
    end
    
    local capabilities = cmp_nvim_lsp.default_capabilities()

    lspconfig.gopls.setup({
        capabilities = capabilities,
        settings = {
            gopls = {
                completeUnimported = true,
                usePlaceholders = true,
                staticcheck = true,
                gofumpt = true,
                codelenses = {
                    generate = true,
                    gc_details = false,
                    regenerate_cgo = true,
                    run_govulncheck = true,
                    test = true,
                    tidy = true,
                    upgrade_dependency = true,
                    vendor = true,
                },
                hints = {
                    assignVariableTypes = true,
                    compositeLiteralFields = true,
                    compositeLiteralTypes = true,
                    constantValues = true,
                    functionTypeParameters = true,
                    parameterNames = true,
                    rangeVariableTypes = true,
                },
                analyses = {
                    fieldalignment = true,
                    nilness = true,
                    unusedparams = true,
                    unusedwrite = true,
                    useany = true,
                },
                directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
                semanticTokens = true,
            },
        },
        filetypes = { "go", "gomod", "gowork", "gotmpl" },
        root_dir = lspconfig.util.root_pattern("go.mod", "go.work", ".git" ),
    })
end

M.formatting = function()
    local ok, conform = pcall(require, "conform")
    if not ok then
        return
    end
    
    -- Get existing formatters or create empty table
    local existing_formatters = conform.formatters_by_ft or {}
    existing_formatters.go = { "goimports", "gofmt" }
    
    -- Configure goimports - try PATH first, fallback to full path
    local goimports_cmd = "goimports"
    if vim.fn.executable("goimports") == 0 then
        goimports_cmd = "/home/barath/go/bin/goimports"
    end
    
    -- Get existing format_on_save function
    local existing_format_on_save = conform.format_on_save
    
    conform.setup({
        formatters_by_ft = existing_formatters,
        formatters = {
            goimports = {
                command = goimports_cmd,
                args = { "-srcdir", "$DIRNAME" },
                stdin = true,
            },
        },
        format_on_save = function(bufnr)
            local filetype = vim.bo[bufnr].filetype
            if filetype == "go" then
                return {
                    lsp_fallback = true,
                    async = false,
                    timeout_ms = 2000,
                }
            end
            -- Call existing format_on_save if it exists
            if existing_format_on_save and type(existing_format_on_save) == "function" then
                return existing_format_on_save(bufnr)
            end
            return nil
        end,
    })
end

M.debugging = function()
    local ok_dap, dap = pcall(require, "dap")
    local ok_dapui, dapui = pcall(require, "dapui")
    local ok_dap_go = pcall(require, "dap-go")
    
    if not ok_dap or not ok_dapui or not ok_dap_go then
        return
    end
    
    require("dap-go").setup({})
    require("dapui").setup({})

    -- Listen for DAP events
    dap.listeners.before.event_initialized["dapui_config"] = function()
        dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
    end

    -- Keymaps for debugging
    local map = vim.api.nvim_set_keymap
    local options = { noremap = true, silent = true }

    map("n", "<leader>db", "<cmd>lua require'dap'.toggle_breakpoint()<CR>", options)
    map("n", "<leader>dc", "<cmd>lua require'dap'.continue()<CR>", options)
    map("n", "<leader>do", "<cmd>lua require'dap'.step_over()<CR>", options)
    map("n", "<leader>di", "<cmd>lua require'dap'.step_into()<CR>", options)
    map("n", "<leader>dq", "<cmd>lua require'dap'.terminate()<CR>", options)
end

-- Add Go-specific keymaps
M.keymaps = function()
    -- Go-specific keymaps
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "go",
        callback = function()
            local bufnr = vim.api.nvim_get_current_buf()
            local opts = { noremap = true, silent = true, buffer = bufnr }
            
            -- Manual import organization
            vim.keymap.set("n", "<leader>go", function()
                vim.lsp.buf.code_action({
                    context = { only = { "source.organizeImports" } },
                    apply = true,
                })
            end, vim.tbl_extend("force", opts, { desc = "Organize Go imports" }))
            
            -- Add missing imports
            vim.keymap.set("n", "<leader>gi", function()
                vim.lsp.buf.code_action({
                    context = { only = { "source.addMissingImports" } },
                    apply = true,
                })
            end, vim.tbl_extend("force", opts, { desc = "Add missing Go imports" }))
            
            -- Format and organize imports manually
            vim.keymap.set("n", "<leader>gf", function()
                vim.cmd("Format")
            end, vim.tbl_extend("force", opts, { desc = "Format Go file" }))
            
            -- Go-specific build and test commands
            vim.keymap.set("n", "<leader>gb", ":!go build<CR>", vim.tbl_extend("force", opts, { desc = "Go build" }))
            vim.keymap.set("n", "<leader>gt", ":!go test<CR>", vim.tbl_extend("force", opts, { desc = "Go test" }))
            vim.keymap.set("n", "<leader>gr", ":!go run %<CR>", vim.tbl_extend("force", opts, { desc = "Go run current file" }))
            vim.keymap.set("n", "<leader>gm", ":!go mod tidy<CR>", vim.tbl_extend("force", opts, { desc = "Go mod tidy" }))
        end,
    })
end

-- Add Go-specific autocommands
M.autocommands = function()
    -- Go-specific autocommands
    vim.api.nvim_create_augroup("GoSettings", { clear = true })
    
    vim.api.nvim_create_autocmd("FileType", {
        group = "GoSettings",
        pattern = "go",
        callback = function()
            -- Set Go-specific options
            vim.opt_local.expandtab = false
            vim.opt_local.tabstop = 4
            vim.opt_local.shiftwidth = 4
            vim.opt_local.softtabstop = 4
        end,
    })
    
    -- Enhanced format on save for Go files with import organization
    vim.api.nvim_create_autocmd("BufWritePre", {
        group = "GoSettings",
        pattern = "*.go",
        callback = function()
            -- First organize imports via LSP
            vim.lsp.buf.code_action({
                context = { only = { "source.organizeImports" } },
                apply = true,
            })
            
            -- Then format the file
            local ok, conform = pcall(require, "conform")
            if ok then
                conform.format({ async = false, timeout_ms = 2000 })
            else
                vim.lsp.buf.format({ async = false })
            end
        end,
    })
    
    -- Auto-organize imports when adding new imports
    vim.api.nvim_create_autocmd("BufWritePost", {
        group = "GoSettings",
        pattern = "*.go",
        callback = function()
            -- Run go mod tidy if go.mod exists
            if vim.fn.filereadable("go.mod") == 1 then
                vim.fn.system("go mod tidy")
            end
        end,
    })
end

return M
