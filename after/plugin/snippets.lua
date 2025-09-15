local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

ls.add_snippets("markdown", {
  s(
    { trig = "env", dscr = "Linear ENV issue markdown link" },
    fmt("[ENV-{}](https://linear.app/fleet-ai/issue/ENV-{})", { i(1), rep(1) })
  ),
})
