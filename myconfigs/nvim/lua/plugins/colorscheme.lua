return {
  "rose-pine/neovim",
  name = "rose-pine",
  lazy = false, -- load at startup
  priority = 1000, -- high priority to ensure it loads early

  config = function()
    require("rose-pine").setup({
      --- @usage 'main' | 'moon' | 'dawn'
      variant = "main", -- 'main' (dark), 'moon' (darker), 'dawn' (light)
      dark_variant = "main", -- if variant is 'auto', this is the dark variant
      bold_vert_split = false,
      dim_nc_background = false,
      disable_background = false, -- set to true for transparent bg
      disable_float_background = false,
      disable_italics = false,

      --- @usage string hex value or named color from `rose-pine-palette`
      groups = {
        background = "base",
        panel = "surface",
        border = "highlight_med",
        comment = "muted",
        link = "iris",
        punctuation = "subtle",

        error = "love",
        hint = "iris",
        info = "foam",
        warn = "gold",

        headings = {
          h1 = "iris",
          h2 = "foam",
          h3 = "rose",
          h4 = "gold",
          h5 = "pine",
          h6 = "foam",
        },
      },

      -- Change specific vim highlight groups
      highlight_groups = {
        -- Example: Make Telescope border less bright
        -- TelescopeBorder = { fg = 'highlight_med', bg = 'none' },
      },
    })

    -- Set the colorscheme
    vim.cmd("colorscheme rose-pine")
  end,
}
