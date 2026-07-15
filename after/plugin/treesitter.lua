-- nvim-treesitter's query files for the languages Neovim 0.12 bundles natively
-- take precedence in the rtp (they lack "; extends") and contain patterns
-- incompatible with 0.12's query engine, causing node:range() crashes.
-- Override those queries with Neovim's built-in versions.
local builtin_langs = { 'c', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' }
local query_types = { 'highlights', 'injections', 'locals', 'folds', 'indents' }
for _, lang in ipairs(builtin_langs) do
  for _, qtype in ipairs(query_types) do
    local path = vim.env.VIMRUNTIME .. '/queries/' .. lang .. '/' .. qtype .. '.scm'
    local f = io.open(path, 'r')
    if f then
      local content = f:read('*a')
      f:close()
      vim.treesitter.query.set(lang, qtype, content)
    end
  end
end

-- Neovim 0.12 bundles both the parser AND queries for builtin_langs. Letting
-- nvim-treesitter install its own (older) parsers for these shadows the bundled
-- ones on the rtp, so its stale parser gets paired with the built-in query set
-- above -> node-type mismatches (e.g. "vim" parser missing the "tab" node).
-- Keep nvim-treesitter's hands off these: never install, always ignore.
local builtin_set = {}
for _, lang in ipairs(builtin_langs) do builtin_set[lang] = true end

local want = {
    'astro', 'python', 'lua', 'javascript', 'typescript', 'vimdoc', 'vim',
    'regex', 'terraform', 'sql', 'dockerfile', 'toml', 'json', 'go',
    'gitignore', 'yaml', 'make', 'cmake', 'markdown', 'markdown_inline',
    'bash', 'tsx', 'css', 'html',
}
local ensure = {}
for _, lang in ipairs(want) do
  if not builtin_set[lang] then table.insert(ensure, lang) end
end

local ignore = { 'javascript' }
for _, lang in ipairs(builtin_langs) do table.insert(ignore, lang) end

require'nvim-treesitter.configs'.setup {
  ensure_installed = ensure,
  auto_install = true,
  ignore_install = ignore,
  highlight = {
    enable = false, -- nvim-treesitter highlight unsupported on Neovim 0.12+; built-in handles it
  },
}
