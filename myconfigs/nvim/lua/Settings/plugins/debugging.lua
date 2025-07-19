return{
    "mfussenegger/nvim-dap",
    dependencies = {
        "nvim-neotest/nvim-nio",
        "rcarriga/nvim-dap-ui",
        "leoluz/nvim-dap-go",
        "theHamsta/nvim-dap-virtual-text",
    },

    config = function()
        local dap = require("dap")
        local dapui = require("dapui")

        -- Setup dap-go with enhanced configuration
        require("dap-go").setup({
            -- Additional dap configurations can be added.
            -- dap_configurations accepts a list of tables where each entry
            -- represents a dap configuration. For more details do:
            -- :help dap-configuration
            dap_configurations = {
                {
                    type = "go",
                    name = "Attach remote",
                    mode = "remote",
                    request = "attach",
                },
            },
            -- delve configurations
            delve = {
                -- the path to the executable dlv which will be used for debugging.
                -- by default, this is the "dlv" executable on your PATH.
                path = "dlv",
                -- time to wait for delve to initialize the debug session.
                -- default to 20 seconds
                initialize_timeout_sec = 20,
                -- a string that defines the port to start delve debugger.
                -- default to string "${port}" which instructs nvim-dap
                -- to start the process in a random available port
                port = "${port}",
                -- additional args to pass to dlv
                args = {},
                -- the build flags that are passed to delve.
                -- defaults to empty string, but can be used to provide flags
                -- such as "-tags=unit" to make sure the test suite is
                -- compiled during debugging, for example.
                -- passing build flags using args is ineffective, as those are
                -- ignored by delve in dap mode.
                build_flags = "",
                -- whether the dlv process to be created detached or not. there is
                -- an issue on Windows where this needs to be set to false
                -- otherwise the dlv process will not be created properly, see:
                -- https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
                detached = vim.fn.has("win32") == 0,
            },
        })
        
        -- Setup dap-ui with better configuration
        require("dapui").setup({
            icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
            mappings = {
                -- Use a table to apply multiple mappings
                expand = { "<CR>", "<2-LeftMouse>" },
                open = "o",
                remove = "d",
                edit = "e",
                repl = "r",
                toggle = "t",
            },
            -- Use this to override mappings for specific elements
            element_mappings = {},
            expand_lines = vim.fn.has("nvim-0.7") == 1,
            layouts = {
                {
                    elements = {
                        -- Elements can be strings or table with id and size keys.
                        { id = "scopes", size = 0.25 },
                        "breakpoints",
                        "stacks",
                        "watches",
                    },
                    size = 40, -- 40 columns
                    position = "left",
                },
                {
                    elements = {
                        "repl",
                        "console",
                    },
                    size = 0.25, -- 25% of total lines
                    position = "bottom",
                },
            },
            controls = {
                enabled = true,
                -- Display controls in this element
                element = "repl",
                icons = {
                    pause = "",
                    play = "",
                    step_into = "",
                    step_over = "",
                    step_out = "",
                    step_back = "",
                    run_last = "↻",
                    terminate = "□",
                },
            },
        })
        
        -- Setup virtual text for debugging
        require("nvim-dap-virtual-text").setup({
            enabled = true,                        -- enable this plugin (the default)
            enabled_commands = true,               -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
            highlight_changed_variables = true,    -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
            highlight_new_as_changed = false,      -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
            show_stop_reason = true,               -- show stop reason when stopped for exceptions
            commented = false,                     -- prefix virtual text with comment string
            only_first_definition = true,          -- only show virtual text at first definition (if there are multiple)
            all_references = false,                -- show virtual text on all all references of the variable (not only definitions)
            clear_on_continue = false,             -- clear virtual text on "continue" (might cause flickering when stepping)
            display_callback = function(variable, buf, stackframe, node, options)
                if options.virt_text_pos == 'inline' then
                    return ' = ' .. variable.value
                else
                    return variable.name .. ' = ' .. variable.value
                end
            end,
        })

        -- Listeners for automatically opening/closing DAP UI
        dap.listeners.before.attach.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.launch.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.event_terminated.dapui_config = function()
            dapui.close()
        end
        dap.listeners.before.event_exited.dapui_config = function()
            dapui.close()
        end

        -- Enhanced keymaps for debugging
        local opts = { noremap = true, silent = true }
        
        -- Basic debugging controls
        vim.keymap.set("n", "<Leader>db", dap.toggle_breakpoint, vim.tbl_extend("force", opts, { desc = "Toggle breakpoint" }))
        vim.keymap.set("n", "<Leader>dB", function() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, vim.tbl_extend("force", opts, { desc = "Set conditional breakpoint" }))
        vim.keymap.set("n", "<Leader>dc", dap.continue, vim.tbl_extend("force", opts, { desc = "Continue" }))
        vim.keymap.set("n", "<Leader>dC", dap.run_to_cursor, vim.tbl_extend("force", opts, { desc = "Run to cursor" }))
        vim.keymap.set("n", "<Leader>dg", dap.goto_, vim.tbl_extend("force", opts, { desc = "Go to line (no execute)" }))
        vim.keymap.set("n", "<Leader>di", dap.step_into, vim.tbl_extend("force", opts, { desc = "Step into" }))
        vim.keymap.set("n", "<Leader>dj", dap.down, vim.tbl_extend("force", opts, { desc = "Down" }))
        vim.keymap.set("n", "<Leader>dk", dap.up, vim.tbl_extend("force", opts, { desc = "Up" }))
        vim.keymap.set("n", "<Leader>dl", dap.run_last, vim.tbl_extend("force", opts, { desc = "Run last" }))
        vim.keymap.set("n", "<Leader>do", dap.step_out, vim.tbl_extend("force", opts, { desc = "Step out" }))
        vim.keymap.set("n", "<Leader>dO", dap.step_over, vim.tbl_extend("force", opts, { desc = "Step over" }))
        vim.keymap.set("n", "<Leader>dp", dap.pause, vim.tbl_extend("force", opts, { desc = "Pause" }))
        vim.keymap.set("n", "<Leader>dr", dap.repl.toggle, vim.tbl_extend("force", opts, { desc = "Toggle REPL" }))
        vim.keymap.set("n", "<Leader>ds", dap.session, vim.tbl_extend("force", opts, { desc = "Session" }))
        vim.keymap.set("n", "<Leader>dt", dap.terminate, vim.tbl_extend("force", opts, { desc = "Terminate" }))
        vim.keymap.set("n", "<Leader>dw", function()
            local widgets = require("dap.ui.widgets")
            widgets.sidebar(widgets.scopes).open()
        end, vim.tbl_extend("force", opts, { desc = "Widgets" }))
        
        -- DAP UI controls
        vim.keymap.set("n", "<Leader>dui", dapui.toggle, vim.tbl_extend("force", opts, { desc = "Toggle DAP UI" }))
        
        -- Go-specific debugging
        vim.keymap.set("n", "<Leader>dgt", function() require('dap-go').debug_test() end, vim.tbl_extend("force", opts, { desc = "Debug go test" }))
        vim.keymap.set("n", "<Leader>dgl", function() require('dap-go').debug_last_test() end, vim.tbl_extend("force", opts, { desc = "Debug last go test" }))
    end,
}
