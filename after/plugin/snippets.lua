local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

local snippets = {
  s(
    { trig = "td", dscr = "Todo checkbox" },
    fmt("- [ ] {}", { i(1) })
  ),
}

local linear_workspace, linear_project = string.match(os.getenv("LINEAR_PROJECT") or "", "^(.+)/(.+)$")
if linear_workspace and linear_project then
  table.insert(
    snippets,
    s(
      { trig = "tick", dscr = "Linear issue markdown link" },
      fmt(
        "[" .. linear_project .. "-{}](https://linear.app/" .. linear_workspace .. "/issue/" .. linear_project .. "-{})",
        { i(1), rep(1) }
      )
    )
  )
end

ls.add_snippets("markdown", snippets)
