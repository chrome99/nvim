require('lualine').setup({
    options = {
        icons_enabled = true,
        section_separators = { left = '', right = '' },
        component_separators = { left = '', right = '' },
        disabled_filetypes = { 'alpha', 'neo-tree' },
        always_divide_middle = true,
    },
    sections = {
        lualine_a = {
            {
                'mode',
                fmt = function(str)
                    return ' ' .. str
                end,
            },
        },
        lualine_b = { 'branch' },
        lualine_c = {
            {
                'filename',
                file_status = true, -- displays file status (readonly status, modified status)
                path = 0, -- 0 = just filename, 1 = relative path, 2 = absolute path
            },
        },
        lualine_x = {
            {
                'diagnostics',
                sources = { 'nvim_diagnostic' },
                sections = { 'error', 'warn' },
                symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
                colored = false,
                update_in_insert = false,
                always_visible = false,
                cond = function()
                    return vim.fn.winwidth(0) > 100
                end,
            },
            {
                'diff',
                colored = false,
                symbols = { added = ' ', modified = ' ', removed = ' ' },
                cond = function()
                    return vim.fn.winwidth(0) > 100
                end,
            },
            { 'encoding', cond = function() return vim.fn.winwidth(0) > 100 end },
            { 'filetype', cond = function() return vim.fn.winwidth(0) > 100 end },
        },
        lualine_y = { 'location' },
        lualine_z = { 'progress' },
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = { { 'location', padding = 0 } },
        lualine_y = {},
        lualine_z = {},
    },
    tabline = {},
    extensions = { 'fugitive' },
})
