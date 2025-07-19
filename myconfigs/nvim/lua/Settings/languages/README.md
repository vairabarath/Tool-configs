# Language-Specific Configuration

This directory contains modular, language-specific configurations for Neovim. Each programming language has its own dedicated configuration file that manages LSP, formatting, debugging, linting, keymaps, plugins, and autocommands.

## Structure

```
languages/
├── init.lua          # Language manager
├── go.lua             # Go configuration
├── rust.lua           # Rust configuration
├── web.lua            # Web development (JS/TS/HTML/CSS)
└── README.md          # This file
```

## Language Manager (`init.lua`)

The language manager provides a centralized way to manage all language configurations:

- `setup_all()`: Initialize all language configurations
- `setup_language(lang_name)`: Initialize a specific language
- `get_languages()`: Get list of available languages
- `add_language(lang_name, config)`: Add a new language configuration
- `get_all_plugins()`: Collect plugins from all languages for lazy.nvim

## Creating a New Language Configuration

To add support for a new programming language:

1. Create a new file: `lua/Settings/languages/your_language.lua`
2. Use this template:

```lua
local M = {}

M.lspconfig = function()
    local lspconfig = require("lspconfig")
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    
    -- Configure your language server here
    lspconfig.your_ls.setup({
        capabilities = capabilities,
        -- Your LSP settings
    })
end

M.formatting = function()
    local conform = require("conform")
    -- Configure formatters
end

M.linting = function()
    local lint = require("lint")
    -- Configure linters
end

M.debugging = function()
    local dap = require("dap")
    -- Configure debugging
end

M.keymaps = function()
    -- Language-specific keymaps
end

M.autocommands = function()
    -- Language-specific autocommands
end

M.plugins = function()
    return {
        -- Language-specific plugins
    }
end

return M
```

3. Add your language to `languages/init.lua`:

```lua
local languages = {
    go = require("Settings.languages.go"),
    rust = require("Settings.languages.rust"),
    web = require("Settings.languages.web"),
    your_language = require("Settings.languages.your_language"), -- Add this line
}
```

## Current Language Support

### Go (`go.lua`)
- **LSP**: gopls with enhanced settings
- **Formatting**: goimports, gofmt (auto-format on save)
- **Debugging**: delve via nvim-dap-go
- **Features**: Code lenses, inlay hints, static analysis

### Rust (`rust.lua`)
- **LSP**: rust-analyzer with comprehensive settings
- **Formatting**: rustfmt (auto-format on save)
- **Debugging**: codelldb adapter
- **Linting**: clippy
- **Plugins**: rustaceanvim, crates.nvim, rust.vim
- **Keymaps**: Cargo commands, rust-specific actions

### Web Development (`web.lua`)
- **Languages**: JavaScript, TypeScript, HTML, CSS, Svelte
- **LSP**: ts_ls, denols, emmet, html, css, json
- **Formatting**: biome-check, prettier
- **Linting**: eslint_d
- **Plugins**: typescript-tools, package-info, nvim-ts-autotag
- **Keymaps**: npm commands, TypeScript actions

## Key Features

### Modular Organization
- Each language is completely self-contained
- Easy to enable/disable specific languages
- Clean separation of concerns

### Automatic Integration
- Plugins are automatically loaded via lazy.nvim
- LSP configurations are set up on initialization
- Format-on-save works per language

### Extensible Design
- Easy to add new languages
- Consistent API across all languages
- Error handling and logging

## Usage Examples

### Enable specific language
```lua
local language_manager = require("Settings.languages")
language_manager.setup_language("rust")
```

### Get available languages
```lua
local languages = require("Settings.languages").get_languages()
print(vim.inspect(languages)) -- { "go", "rust", "web" }
```

### Add custom language
```lua
local my_python_config = require("my.python.config")
require("Settings.languages").add_language("python", my_python_config)
```

## Language-Specific Keymaps

### Go
- `<leader>` + Go-specific debugging commands

### Rust  
- `<leader>rr`: Rust runnables
- `<leader>rt`: Run tests
- `<leader>rc`: Open Cargo.toml
- `<leader>cb`: Cargo build
- `<leader>ct`: Cargo test

### Web Development
- `<leader>co`: Organize imports (TypeScript)
- `<leader>ni`: npm install
- `<leader>ns`: npm start
- `<leader>nb`: npm build

## Benefits

1. **Clean Organization**: No more monolithic configuration files
2. **Easy Maintenance**: Update one language without affecting others
3. **Selective Loading**: Only load what you need
4. **Consistent Structure**: Same pattern across all languages
5. **Future-Proof**: Easy to add new languages as they emerge
