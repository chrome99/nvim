-- linear.lua
local M = {}

local EMAIL = os.getenv("LINEAR_EMAIL")
local LIMIT = 10
local ENDPOINT = "https://api.linear.app/graphql"

local QUERY = [[
query InProgressByEmail($email: String!, $first: Int!) {
  users(filter: { email: { eq: $email } }) {
    nodes {
      assignedIssues(
        first: $first
        filter: { state: { type: { eq: "started" } } }
        orderBy: updatedAt
      ) {
        nodes { title identifier url }
      }
    }
  }
}]]

local function http(body)
  local key = vim.fn.getenv("LINEAR_API_KEY")
  if key == vim.NIL or key == "" then
    return nil, "Missing LINEAR_API_KEY"
  end

  -- Neovim 0.10+: vim.system with {text = body}
  local proc = vim.system({
    "curl",
    "-sS",
    ENDPOINT,
    "-H",
    "Content-Type: application/json",
    "-H",
    "Accept: application/json",
    "-H",
    "Authorization: " .. key,
    "-d",
    body,
  })

  if not proc then
    return nil, "Failed to create process"
  end

  local ok, res = pcall(proc.wait, proc)

  if not ok then
    return nil, "curl failed"
  end
  if res.code ~= 0 then
    return nil, ("curl exit %d: %s"):format(res.code, res.stderr)
  end
  return res.stdout, nil
end

function M.insert_in_progress(limit)
  if not EMAIL or EMAIL == "" then
    vim.notify("Missing LINEAR_EMAIL", vim.log.levels.ERROR)
    return
  end
  limit = tonumber(limit) or LIMIT
  local body = vim.json.encode({ query = QUERY, variables = { email = EMAIL, first = limit } })
  local out, err = http(body)
  if not out then
    vim.notify(err, vim.log.levels.ERROR)
    return
  end

  local ok, json = pcall(vim.json.decode, out)
  if not ok then
    vim.notify("Bad JSON from Linear", vim.log.levels.ERROR)
    return
  end
  if json.errors then
    vim.notify(vim.inspect(json.errors), vim.log.levels.ERROR)
    return
  end

  local user = json.data.users.nodes[0] or json.data.users.nodes[1] -- Lua arrays start at 1
  user = user or json.data.users.nodes[1]
  if not user then
    vim.notify("No Linear user for " .. EMAIL, vim.log.levels.WARN)
    return
  end

  local issues = user.assignedIssues.nodes or {}
  if #issues == 0 then
    vim.notify("No in-progress issues", vim.log.levels.INFO)
    return
  end

  local lines = {}
  for _, i in ipairs(issues) do
    local url_without_slug = i.url:gsub("[^/]*$", "")
    table.insert(lines, ("- [%s](%s)"):format(i.identifier, url_without_slug))
  end

  -- insert at cursor (below)
  vim.api.nvim_put(lines, "l", true, true)
end

-- :LinearInProgress [n]  -> fetch n (default 10)
vim.api.nvim_create_user_command("Linear", function(opts)
  M.insert_in_progress(opts.args)
end, { nargs = "?" })

-- Insert In-Progress Linear tickets
vim.keymap.set("n", "<leader>li", function()
  M.insert_in_progress()
end, { desc = "Insert Linear in-progress" })

local workspace, prefix = string.match(os.getenv("LINEAR_PROJECT") or "", "^(.+)/(.+)$")

-- The issue key under the cursor, e.g. "ABC-1", or nil if the cursor is not on one.
local function issue_key_under_cursor()
  local line = vim.api.nvim_get_current_line()
  local cursor = vim.api.nvim_win_get_cursor(0)[2] + 1
  local search_from = 1

  while true do
    local first, last = line:find(prefix .. "%-%d+", search_from)
    if not first then
      return nil
    end

    local preceded_by_word = first > 1 and line:sub(first - 1, first - 1):match("[%w_]")
    local under_cursor = cursor >= first and cursor <= last
    if under_cursor and not preceded_by_word then
      return line:sub(first, last)
    end

    search_from = first + 1
  end
end

-- Everything the hover float shows about an issue, keyed by issue key so a
-- second hover on the same key never hits the network again.
local issue_cache = {}

local HOVER_QUERY = [[
query Issue($id: String!) {
  issue(id: $id) {
    identifier
    title
    state { name }
    assignee { displayName }
    priorityLabel
    labels { nodes { name } }
    description
  }
}]]

-- Fetch an issue in the background and hand it to `callback` on the main loop,
-- or nil if it could not be fetched.
local function fetch_issue(key, callback)
  local api_key = vim.fn.getenv("LINEAR_API_KEY")
  if api_key == vim.NIL or api_key == "" then
    return callback(nil, "Missing LINEAR_API_KEY")
  end

  local body = vim.json.encode({ query = HOVER_QUERY, variables = { id = key } })

  vim.system({
    "curl",
    "-sS",
    ENDPOINT,
    "-H",
    "Content-Type: application/json",
    "-H",
    "Accept: application/json",
    "-H",
    "Authorization: " .. api_key,
    "-d",
    body,
  }, { text = true }, function(res)
    local issue, err

    if res.code ~= 0 then
      err = ("curl exit %d: %s"):format(res.code, res.stderr)
    else
      -- luanil turns JSON nulls into nil, so absent fields read as absent
      -- instead of as vim.NIL, which is truthy and blows up on index.
      local ok, json = pcall(vim.json.decode, res.stdout, { luanil = { object = true } })
      if not ok then
        err = "Bad JSON from Linear"
      elseif json.data and json.data.issue then
        issue = json.data.issue
        issue_cache[key] = issue
      else
        -- Say what Linear said. A key the token cannot see reads the same as
        -- a typo, and an expired token says so outright; neither is worth
        -- flattening into "not found".
        err = json.errors and json.errors[1] and json.errors[1].message or "not found"
      end
    end

    vim.schedule(function()
      callback(issue, err)
    end)
  end)
end

-- The issue as markdown lines: a title line, a metadata line, then the body.
local function issue_markdown(issue)
  local lines = { ("**%s** — %s"):format(issue.identifier, issue.title), "" }

  local meta = {}
  if issue.state then
    table.insert(meta, issue.state.name)
  end
  table.insert(meta, issue.assignee and issue.assignee.displayName or "Unassigned")
  if issue.priorityLabel then
    table.insert(meta, issue.priorityLabel)
  end
  for _, label in ipairs(issue.labels and issue.labels.nodes or {}) do
    table.insert(meta, label.name)
  end
  table.insert(lines, table.concat(meta, "  ·  "))

  if issue.description and issue.description ~= "" then
    table.insert(lines, "")
    vim.list_extend(lines, vim.split(issue.description, "\n", { plain = true }))
  end

  return lines
end

local function float(lines)
  local _, win = vim.lsp.util.open_floating_preview(lines, "markdown", {
    border = "rounded",
    max_width = 80,
    max_height = 24,
  })
  return win
end

-- The issue in a real buffer, for a ticket too long to read in a float. It is
-- a scratch buffer named after the key, so a second visit reuses it and gx on
-- the issue links inside it opens them in the browser.
local function open_buffer(issue)
  local name = "linear://" .. issue.identifier
  local buf = vim.fn.bufnr(name)

  if buf == -1 then
    buf = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_buf_set_name(buf, name)
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "hide"
    vim.bo[buf].swapfile = false
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, issue_markdown(issue))
    vim.bo[buf].modifiable = false
    vim.bo[buf].filetype = "markdown"
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, desc = "Close Linear issue" })
  end

  vim.cmd("botright vsplit")
  vim.api.nvim_win_set_buf(0, buf)
  vim.api.nvim_win_set_width(0, 84)
  vim.wo.wrap = true
end

if workspace and prefix then
  local open_under_cursor = vim.fn.maparg("gx", "n", false, true).callback

  vim.keymap.set("n", "gx", function()
    local key = issue_key_under_cursor()
    if key then
      vim.ui.open(("https://linear.app/%s/issue/%s"):format(workspace, key))
    else
      open_under_cursor()
    end
  end, { desc = "Open Linear issue or URL under cursor" })

  -- The float currently on screen, so a second K on the same key can promote
  -- it to a buffer rather than redrawing the same float.
  local shown_win, shown_key

  local function show(issue)
    shown_key, shown_win = issue.identifier, float(issue_markdown(issue))
  end

  vim.keymap.set("n", "K", function()
    local key = issue_key_under_cursor()
    if not key then
      if next(vim.lsp.get_clients({ bufnr = 0, method = "textDocument/hover" })) then
        return vim.lsp.buf.hover()
      end
      return vim.cmd("normal! K")
    end

    if shown_key == key and shown_win and vim.api.nvim_win_is_valid(shown_win) then
      vim.api.nvim_win_close(shown_win, true)
      shown_win = nil
      return open_buffer(issue_cache[key])
    end

    local cached = issue_cache[key]
    if cached then
      return show(cached)
    end

    local loading = float({ ("Loading %s…"):format(key) })

    fetch_issue(key, function(issue, err)
      if loading and vim.api.nvim_win_is_valid(loading) then
        vim.api.nvim_win_close(loading, true)
      end
      -- The cursor may have wandered off the key while curl was in flight.
      if issue_key_under_cursor() ~= key then
        return
      end
      if issue then
        show(issue)
      else
        vim.notify(("%s: %s"):format(key, err or "not found"), vim.log.levels.WARN)
      end
    end)
  end, { desc = "Hover Linear issue under cursor" })
end

return M
