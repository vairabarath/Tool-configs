local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Load language-specific plugins
local language_manager = require("Settings.languages")
local language_plugins = language_manager.get_all_plugins()

require("lazy").setup(
    vim.list_extend({
        { import = "Settings.plugins" },
        { import = "Settings.plugins.lsp" },
    }, language_plugins),
    {
        checker = {
            enabled = true,
            notify = false,
        },
        change_detection = {
            notify = false,
        },
    }
)

-- Setup language configurations after plugins are loaded
vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function()
        language_manager.setup_plugin_dependent_configs()
    end,
})
