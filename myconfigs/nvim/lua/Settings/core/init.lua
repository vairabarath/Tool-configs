-- Load and setup all language-specific configurations
-- Note: Plugin-dependent configs are set up after plugins load via VeryLazy autocmd in lazy.lua
local language_manager = require("Settings.languages")
language_manager.setup_all()

-- Load core configurations
require('Settings.core.options')
require("Settings.core.keymaps")
require("Settings.core.commands")
