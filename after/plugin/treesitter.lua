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
-- Keep nvim-treesitter's hands off these: never install them.
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

-- nvim-treesitter's `main` branch dropped the `nvim-treesitter.configs` module
-- along with ensure_installed/auto_install/ignore_install/highlight. Parsers are
-- now installed explicitly via require('nvim-treesitter').install(); highlight is
-- Neovim's own vim.treesitter.start().
local ts = require('nvim-treesitter')

-- install() re-fetches unconditionally, so only ask for what's actually missing.
local have = {}
for _, lang in ipairs(ts.get_installed('parsers')) do have[lang] = true end

local missing = {}
for _, lang in ipairs(ensure) do
  if not have[lang] and not builtin_set[lang] then table.insert(missing, lang) end
end

if #missing > 0 then
  -- The `main` branch shells out to the tree-sitter CLI to build grammars. Without
  -- it every parser downloads, fails to compile, and is retried on the next
  -- startup -- an endless "Downloading tree-sitter-x..." loop. Say so once instead.
  if vim.fn.executable('tree-sitter') == 0 then
    vim.schedule(function()
      vim.notify(
        'nvim-treesitter: tree-sitter CLI not found, skipping install of '
          .. #missing .. ' parser(s). Install it with: pacman -S tree-sitter-cli',
        vim.log.levels.WARN
      )
    end)
  else
    ts.install(missing)
  end
end
