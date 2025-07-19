-- Language Manager
-- Centralized management of language-specific configurations

local M = {}

-- Available language configurations
local languages = {
    go = require("Settings.languages.go"),
    rust = require("Settings.languages.rust"),
    web = require("Settings.languages.web"),
}

-- Function to setup a specific language
M.setup_language = function(lang_name)
    local lang = languages[lang_name]
    if not lang then
        vim.notify("Language configuration '" .. lang_name .. "' not found", vim.log.levels.WARN)
        return
    end

    -- Setup language components in order, but skip plugins (they're handled by lazy.nvim)
    local components = { "keymaps", "autocommands" }
    
    for _, component in ipairs(components) do
        if lang[component] and type(lang[component]) == "function" then
            local ok, err = pcall(lang[component])
            if not ok then
                vim.notify("Error setting up " .. component .. " for " .. lang_name .. ": " .. err, vim.log.levels.ERROR)
            end
        end
    end
end

-- Function to setup language configs that depend on plugins (called after plugins are loaded)
M.setup_plugin_dependent_configs = function()
    for lang_name, lang in pairs(languages) do
        -- Setup components that depend on plugins being loaded first
        local components = { "lspconfig", "formatting", "linting", "debugging" }
        
        for _, component in ipairs(components) do
            if lang[component] and type(lang[component]) == "function" then
                local ok, err = pcall(lang[component])
                if not ok then
                    vim.notify("Error setting up " .. component .. " for " .. lang_name .. ": " .. err, vim.log.levels.ERROR)
                end
            end
        end
    end
end

-- Function to setup all languages
M.setup_all = function()
    for lang_name, _ in pairs(languages) do
        M.setup_language(lang_name)
    end
end

-- Function to get available languages
M.get_languages = function()
    local lang_list = {}
    for lang_name, _ in pairs(languages) do
        table.insert(lang_list, lang_name)
    end
    return lang_list
end

-- Function to add a new language configuration
M.add_language = function(lang_name, config)
    languages[lang_name] = config
    vim.notify("Added language configuration for " .. lang_name, vim.log.levels.INFO)
end

-- Function to get plugins from all languages
M.get_all_plugins = function()
    local all_plugins = {}
    
    for lang_name, lang in pairs(languages) do
        if lang.plugins and type(lang.plugins) == "function" then
            local ok, plugins = pcall(lang.plugins)
            if ok and type(plugins) == "table" then
                for _, plugin in ipairs(plugins) do
                    table.insert(all_plugins, plugin)
                end
            end
        end
    end
    
    return all_plugins
end

return M
