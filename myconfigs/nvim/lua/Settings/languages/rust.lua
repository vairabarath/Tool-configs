local M = {}

M.lspconfig = function()
    -- NOTE: LSP configuration is handled by rustaceanvim plugin
    -- We don't need to set up rust-analyzer manually here as it would conflict
    -- rustaceanvim provides a better, more integrated rust-analyzer setup
end

M.formatting = function()
    local ok, conform = pcall(require, "conform")
    if not ok then
        return
    end
    
    -- Add Rust formatters to the existing configuration
    local existing_formatters = conform.formatters_by_ft or {}
    existing_formatters.rust = { "rustfmt" }
    
    conform.setup({
        formatters_by_ft = existing_formatters,
        format_on_save = function(bufnr)
            local filetype = vim.bo[bufnr].filetype
            if filetype == "rust" then
                return {
                    lsp_fallback = true,
                    async = false,
                    timeout_ms = 1000,
                }
            end
            return nil
        end,
    })
end

M.debugging = function()
    local ok, dap = pcall(require, "dap")
    if not ok then
        return
    end
    
    -- Configure Rust debugging adapter
    dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
            -- Change this path to your actual codelldb path
            command = "codelldb",
            args = { "--port", "${port}" },
        },
    }
    
    dap.configurations.rust = {
        {
            name = "Launch file",
            type = "codelldb",
            request = "launch",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
        },
        {
            name = "Attach to process",
            type = "codelldb",
            request = "attach",
            pid = function()
                local handle = io.popen("ps -ax | grep -v grep")
                if handle then
                    local result = handle:read("*a")
                    handle:close()
                    return tonumber(vim.fn.input("Process ID: ", "", ""))
                end
                return nil
            end,
            cwd = "${workspaceFolder}",
        },
    }
end

M.linting = function()
    local ok, lint = pcall(require, "lint")
    if not ok then
        return
    end
    
    -- Add Rust linters to the existing configuration
    local existing_linters = lint.linters_by_ft or {}
    existing_linters.rust = { "clippy" }
    
    lint.linters_by_ft = existing_linters
    
    -- Auto-run linting
    vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        pattern = "*.rs",
        callback = function()
            lint.try_lint()
        end,
    })
end

M.plugins = function()
    return {
        -- Rust-specific plugins
        {
            "mrcjkb/rustaceanvim",
            version = "^4", -- Recommended
            lazy = false, -- This plugin is already lazy
            config = function()
                vim.g.rustaceanvim = {
                    -- Plugin configuration
                    tools = {
                        hover_actions = {
                            auto_focus = true,
                        },
                    },
                    -- LSP configuration
                    server = {
                        on_attach = function(client, bufnr)
                            -- Set up buffer-local keymaps, etc.
                        end,
                        default_settings = {
                            -- rust-analyzer language server configuration
                            ["rust-analyzer"] = {
                                cargo = {
                                    allFeatures = true,
                                    loadOutDirsFromCheck = true,
                                    runBuildScripts = true,
                                },
                                checkOnSave = {
                                    allFeatures = true,
                                    command = "clippy",
                                    extraArgs = { "--no-deps" },
                                },
                                procMacro = {
                                    enable = true,
                                    ignored = {
                                        ["async-trait"] = { "async_trait" },
                                        ["napi-derive"] = { "napi" },
                                        ["async-recursion"] = { "async_recursion" },
                                    },
                                },
                                diagnostics = {
                                    enable = true,
                                    experimental = {
                                        enable = true,
                                    },
                                },
                                hover = {
                                    actions = {
                                        enable = true,
                                    },
                                },
                                lens = {
                                    enable = true,
                                    run = true,
                                    debug = true,
                                    implementations = true,
                                    references = {
                                        adt = { enable = true },
                                        enumVariant = { enable = true },
                                        method = { enable = true },
                                        trait = { enable = true },
                                    },
                                },
                                inlayHints = {
                                    bindingModeHints = { enable = true },
                                    chainingHints = { enable = true },
                                    closingBraceHints = { enable = true },
                                    closureReturnTypeHints = { enable = "always" },
                                    lifetimeElisionHints = { enable = "always" },
                                    maxLength = 25,
                                    parameterHints = { enable = true },
                                    reborrowHints = { enable = "always" },
                                    renderColons = true,
                                    typeHints = {
                                        enable = true,
                                        hideClosureInitialization = false,
                                        hideNamedConstructor = false,
                                    },
                                },
                                completion = {
                                    callable = {
                                        snippets = "fill_arguments",
                                    },
                                },
                                experimental = {
                                    procAttrMacros = true,
                                },
                            },
                        },
                    },
                    -- DAP configuration
                    dap = {
                        adapter = {
                            type = "executable",
                            command = "lldb-vscode",
                            name = "rt_lldb",
                        },
                    },
                }
            end,
        },
        {
            "saecki/crates.nvim",
            ft = { "rust", "toml" },
            config = function()
                require("crates").setup({
                    src = {
                        cmp = {
                            enabled = true,
                        },
                    },
                })
            end,
        },
        {
            "rust-lang/rust.vim",
            ft = "rust",
            init = function()
                vim.g.rustfmt_autosave = 1
            end,
        },
    }
end

M.keymaps = function()
    local opts = { noremap = true, silent = true }
    
    -- Rust-specific keymaps
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "rust",
        callback = function()
            local bufnr = vim.api.nvim_get_current_buf()
            
            -- Rust-specific keymaps
            vim.keymap.set("n", "<leader>rr", ":RustRunnables<CR>", vim.tbl_extend("force", opts, { desc = "Rust runnables", buffer = bufnr }))
            vim.keymap.set("n", "<leader>rt", ":RustTest<CR>", vim.tbl_extend("force", opts, { desc = "Rust test", buffer = bufnr }))
            vim.keymap.set("n", "<leader>rc", ":RustOpenCargo<CR>", vim.tbl_extend("force", opts, { desc = "Open Cargo.toml", buffer = bufnr }))
            vim.keymap.set("n", "<leader>rp", ":RustParentModule<CR>", vim.tbl_extend("force", opts, { desc = "Go to parent module", buffer = bufnr }))
            vim.keymap.set("n", "<leader>rd", ":RustDebuggables<CR>", vim.tbl_extend("force", opts, { desc = "Rust debuggables", buffer = bufnr }))
            vim.keymap.set("n", "<leader>rh", ":RustHoverActions<CR>", vim.tbl_extend("force", opts, { desc = "Rust hover actions", buffer = bufnr }))
            vim.keymap.set("n", "<leader>re", ":RustExpandMacro<CR>", vim.tbl_extend("force", opts, { desc = "Expand macro", buffer = bufnr }))
            
            -- Cargo commands (run from project root)
            vim.keymap.set("n", "<leader>cb", function()
                local cargo_dir = vim.fn.findfile("Cargo.toml", vim.fn.expand("%:p:h") .. ";")
                if cargo_dir ~= "" then
                    local project_dir = vim.fn.fnamemodify(cargo_dir, ":h")
                    vim.cmd("!cd " .. project_dir .. " && cargo build")
                else
                    vim.notify("Cargo.toml not found", vim.log.levels.ERROR)
                end
            end, vim.tbl_extend("force", opts, { desc = "Cargo build", buffer = bufnr }))
            
            vim.keymap.set("n", "<leader>cc", function()
                local cargo_dir = vim.fn.findfile("Cargo.toml", vim.fn.expand("%:p:h") .. ";")
                if cargo_dir ~= "" then
                    local project_dir = vim.fn.fnamemodify(cargo_dir, ":h")
                    vim.cmd("!cd " .. project_dir .. " && cargo check")
                else
                    vim.notify("Cargo.toml not found", vim.log.levels.ERROR)
                end
            end, vim.tbl_extend("force", opts, { desc = "Cargo check", buffer = bufnr }))
            
            vim.keymap.set("n", "<leader>ct", function()
                local cargo_dir = vim.fn.findfile("Cargo.toml", vim.fn.expand("%:p:h") .. ";")
                if cargo_dir ~= "" then
                    local project_dir = vim.fn.fnamemodify(cargo_dir, ":h")
                    vim.cmd("!cd " .. project_dir .. " && cargo test")
                else
                    vim.notify("Cargo.toml not found", vim.log.levels.ERROR)
                end
            end, vim.tbl_extend("force", opts, { desc = "Cargo test", buffer = bufnr }))
            
            vim.keymap.set("n", "<leader>cr", function()
                local cargo_dir = vim.fn.findfile("Cargo.toml", vim.fn.expand("%:p:h") .. ";")
                if cargo_dir ~= "" then
                    local project_dir = vim.fn.fnamemodify(cargo_dir, ":h")
                    vim.cmd("!cd " .. project_dir .. " && cargo run")
                else
                    vim.notify("Cargo.toml not found", vim.log.levels.ERROR)
                end
            end, vim.tbl_extend("force", opts, { desc = "Cargo run", buffer = bufnr }))
            
            -- Show inlay hints
            vim.keymap.set("n", "<leader>rih", function()
                local bufnr = vim.api.nvim_get_current_buf()
                if vim.lsp.inlay_hint and vim.lsp.inlay_hint.enable then
                    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                    vim.notify("Inlay hints enabled")
                else
                    vim.notify("Inlay hints not supported", vim.log.levels.WARN)
                end
            end, vim.tbl_extend("force", opts, { desc = "Show inlay hints", buffer = bufnr }))
            
            -- Show diagnostics
            vim.keymap.set("n", "<leader>rid", function()
                local bufnr = vim.api.nvim_get_current_buf()
                vim.diagnostic.show(nil, bufnr)
                -- Also enable virtual text temporarily if it's disabled globally
                local current_config = vim.diagnostic.config()
                if not current_config.virtual_text then
                    vim.diagnostic.config({ virtual_text = true }, nil)
                end
                vim.notify("Diagnostics shown")
            end, vim.tbl_extend("force", opts, { desc = "Show diagnostics", buffer = bufnr }))
            
            -- Close both inlay hints and diagnostics
            vim.keymap.set("n", "<leader>ric", function()
                local bufnr = vim.api.nvim_get_current_buf()
                -- Disable inlay hints
                if vim.lsp.inlay_hint and vim.lsp.inlay_hint.enable then
                    vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
                end
                -- Hide diagnostics
                vim.diagnostic.hide(nil, bufnr)
                vim.notify("Inlay hints and diagnostics closed")
            end, vim.tbl_extend("force", opts, { desc = "Close inlay hints and diagnostics", buffer = bufnr }))
            end,
        })
end

M.autocommands = function()
    -- Rust-specific autocommands
    vim.api.nvim_create_augroup("RustSettings", { clear = true })
    
    vim.api.nvim_create_autocmd("FileType", {
        group = "RustSettings",
        pattern = "rust",
        callback = function()
            -- Set Rust-specific options
            vim.opt_local.colorcolumn = "100"
            vim.opt_local.textwidth = 100
            
            -- Enable inlay hints by default for Rust files
            vim.defer_fn(function()
                if vim.lsp.inlay_hint and vim.lsp.inlay_hint.enable then
                    local bufnr = vim.api.nvim_get_current_buf()
                    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                end
            end, 1000) -- Delay to ensure LSP is attached
        end,
    })
    
    -- Auto-format on save for Rust files
    vim.api.nvim_create_autocmd("BufWritePre", {
        group = "RustSettings",
        pattern = "*.rs",
        callback = function()
            vim.lsp.buf.format({ async = false })
        end,
    })
end

return M
