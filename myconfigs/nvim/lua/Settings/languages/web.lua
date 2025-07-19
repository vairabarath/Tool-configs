local M = {}

M.lspconfig = function()
    local ok_lsp, lspconfig = pcall(require, "lspconfig")
    local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
    
    if not ok_lsp or not ok_cmp then
        return
    end
    
    local capabilities = cmp_nvim_lsp.default_capabilities()

    -- TypeScript/JavaScript LSP
    lspconfig.ts_ls.setup({
        capabilities = capabilities,
        root_dir = function(fname)
            local util = lspconfig.util
            return not util.root_pattern("deno.json", "deno.jsonc")(fname)
                and util.root_pattern("tsconfig.json", "package.json", "jsconfig.json", ".git")(fname)
        end,
        single_file_support = false,
        init_options = {
            preferences = {
                includeCompletionsWithSnippetText = true,
                includeCompletionsForImportStatements = true,
            },
        },
        on_attach = function(client, bufnr)
            -- Disable tsserver formatting if you're using a separate formatter
            client.server_capabilities.documentFormattingProvider = false
        end,
    })

    -- Deno LSP
    lspconfig.denols.setup({
        capabilities = capabilities,
        root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"),
    })

    -- Emmet LSP
    lspconfig.emmet_ls.setup({
        capabilities = capabilities,
        filetypes = {
            "html",
            "typescriptreact",
            "javascriptreact",
            "css",
            "sass",
            "scss",
            "less",
            "svelte",
        },
    })

    -- Emmet Language Server
    lspconfig.emmet_language_server.setup({
        capabilities = capabilities,
        filetypes = {
            "css",
            "eruby",
            "html",
            "javascript",
            "javascriptreact",
            "less",
            "sass",
            "scss",
            "pug",
            "typescriptreact",
        },
        init_options = {
            includeLanguages = {},
            excludeLanguages = {},
            extensionsPath = {},
            preferences = {},
            showAbbreviationSuggestions = true,
            showExpandedAbbreviation = "always",
            showSuggestionsAsSnippets = false,
            syntaxProfiles = {},
            variables = {},
        },
    })

    -- HTML LSP
    lspconfig.html.setup({
        capabilities = capabilities,
        filetypes = { "html", "templ" },
    })

    -- CSS LSP
    lspconfig.cssls.setup({
        capabilities = capabilities,
    })

    -- JSON LSP
    lspconfig.jsonls.setup({
        capabilities = capabilities,
    })
end

M.formatting = function()
    local ok, conform = pcall(require, "conform")
    if not ok then
        return
    end
    
    -- Add web dev formatters to the existing configuration
    local existing_formatters = conform.formatters_by_ft or {}
    
    existing_formatters.javascript = { "biome-check" }
    existing_formatters.typescript = { "biome-check" }
    existing_formatters.javascriptreact = { "biome-check" }
    existing_formatters.typescriptreact = { "biome-check" }
    existing_formatters.css = { "biome-check" }
    existing_formatters.html = { "biome-check" }
    existing_formatters.svelte = { "prettier" }
    existing_formatters.json = { "prettier" }
    existing_formatters.yaml = { "prettier" }
    existing_formatters.graphql = { "prettier" }
    existing_formatters.liquid = { "prettier" }
    existing_formatters.markdown = { "prettier", "markdown-toc" }
    
    conform.setup({
        formatters_by_ft = existing_formatters,
        format_on_save = function(bufnr)
            local filetype = vim.bo[bufnr].filetype
            local web_filetypes = {
                "javascript", "typescript", "javascriptreact", "typescriptreact",
                "css", "html", "svelte", "json", "yaml", "graphql", "liquid", "markdown"
            }
            
            for _, ft in ipairs(web_filetypes) do
                if filetype == ft then
                    return {
                        lsp_fallback = true,
                        async = false,
                        timeout_ms = 1000,
                    }
                end
            end
            return nil
        end,
    })

    -- Configure individual formatters
    conform.formatters.prettier = {
        args = {
            "--stdin-filepath",
            "$FILENAME",
            "--tab-width",
            "4",
            "--use-tabs",
            "false",
        },
    }
end

M.linting = function()
    local ok, lint = pcall(require, "lint")
    if not ok then
        return
    end
    
    -- Add web dev linters to the existing configuration
    local existing_linters = lint.linters_by_ft or {}
    existing_linters.javascript = { "eslint_d" }
    existing_linters.typescript = { "eslint_d" }
    existing_linters.javascriptreact = { "eslint_d" }
    existing_linters.typescriptreact = { "eslint_d" }
    existing_linters.svelte = { "eslint_d" }
    
    lint.linters_by_ft = existing_linters
    
    -- Auto-run linting
    vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        pattern = { "*.js", "*.ts", "*.jsx", "*.tsx", "*.svelte" },
        callback = function()
            lint.try_lint()
        end,
    })
end

M.keymaps = function()
    local opts = { noremap = true, silent = true }
    
    -- Web development specific keymaps
    vim.api.nvim_create_autocmd("FileType", {
        pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact", "html", "css", "svelte" },
        callback = function()
            local bufnr = vim.api.nvim_get_current_buf()
            
            -- TypeScript/JavaScript specific keymaps
            vim.keymap.set("n", "<leader>co", ":TSToolsOrganizeImports<CR>", vim.tbl_extend("force", opts, { desc = "Organize imports", buffer = bufnr }))
            vim.keymap.set("n", "<leader>cR", ":TSToolsRenameFile<CR>", vim.tbl_extend("force", opts, { desc = "Rename file", buffer = bufnr }))
            vim.keymap.set("n", "<leader>ci", ":TSToolsAddMissingImports<CR>", vim.tbl_extend("force", opts, { desc = "Add missing imports", buffer = bufnr }))
            vim.keymap.set("n", "<leader>cu", ":TSToolsRemoveUnused<CR>", vim.tbl_extend("force", opts, { desc = "Remove unused imports", buffer = bufnr }))
            vim.keymap.set("n", "<leader>cf", ":TSToolsFixAll<CR>", vim.tbl_extend("force", opts, { desc = "Fix all issues", buffer = bufnr }))
            
            -- Package.json commands
            vim.keymap.set("n", "<leader>ni", ":!npm install<CR>", vim.tbl_extend("force", opts, { desc = "npm install", buffer = bufnr }))
            vim.keymap.set("n", "<leader>ns", ":!npm start<CR>", vim.tbl_extend("force", opts, { desc = "npm start", buffer = bufnr }))
            vim.keymap.set("n", "<leader>nb", ":!npm run build<CR>", vim.tbl_extend("force", opts, { desc = "npm build", buffer = bufnr }))
            vim.keymap.set("n", "<leader>nt", ":!npm test<CR>", vim.tbl_extend("force", opts, { desc = "npm test", buffer = bufnr }))
        end,
    })
end

M.plugins = function()
    return {
        -- TypeScript/JavaScript enhancements
        {
            "pmizio/typescript-tools.nvim",
            dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
            opts = {},
        },
        
        -- Package.json management
        {
            "vuki656/package-info.nvim",
            dependencies = "MunifTanjim/nui.nvim",
            config = function()
                require("package-info").setup()
            end,
        },
        
        -- Better syntax highlighting for web technologies
        {
            "windwp/nvim-ts-autotag",
            config = function()
                require("nvim-ts-autotag").setup()
            end,
        },
    }
end

M.autocommands = function()
    -- Web development specific autocommands
    vim.api.nvim_create_augroup("WebDevSettings", { clear = true })
    
    -- Set specific indentation for web files
    vim.api.nvim_create_autocmd("FileType", {
        group = "WebDevSettings",
        pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact", "json", "html", "css", "svelte" },
        callback = function()
            vim.opt_local.tabstop = 2
            vim.opt_local.shiftwidth = 2
            vim.opt_local.expandtab = true
        end,
    })
    
    -- Auto-format on save for web files
    vim.api.nvim_create_autocmd("BufWritePre", {
        group = "WebDevSettings",
        pattern = { "*.js", "*.ts", "*.jsx", "*.tsx", "*.html", "*.css", "*.json", "*.svelte" },
        callback = function()
            require("conform").format({ async = false })
        end,
    })
end

return M
