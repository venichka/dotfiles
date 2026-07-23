local A = vim.api

-- Custom filetypes
vim.filetype.add({
    extension = {
        eslintrc = 'json',
        prettierrc = 'json',
        conf = 'conf',
        mdx = 'markdown',
        mjml = 'html',
        sage = 'sage',      -- SageMath scripts (highlighted as python, see below)
        cdb = 'cadabra',    -- Cadabra scripts (for the iron REPL)
    },
    pattern = {
        ['.*%.env.*'] = 'sh',
        ['ignore$'] = 'conf',
    },
    filename = {
        ['yup.lock'] = 'yaml',
    },
})

local num_au = A.nvim_create_augroup('NUMTOSTR', { clear = true })

-- Highlight the region on yank
A.nvim_create_autocmd('TextYankPost', {
    group = num_au,
    callback = function()
        vim.highlight.on_yank({ higroup = 'Visual' })
    end,
})

-- Sage: highlight via the Python treesitter grammar, but keep a distinct 'sage'
-- filetype so the python LSP (pylsp) does NOT attach — highlighting, no linting.
vim.treesitter.language.register('python', 'sage')
A.nvim_create_autocmd('FileType', {
    group = num_au,
    pattern = 'sage',
    callback = function(ev)
        pcall(vim.treesitter.start, ev.buf, 'python')
        vim.bo[ev.buf].commentstring = '# %s'
    end,
})
