-- linear.lua
local M = {}

-- hardcode your email + default limit
local EMAIL = "ezra@10play.dev"
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
    table.insert(lines, ("- [ ] %s [%s](%s)"):format(i.title, i.identifier, i.url))
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

return M
