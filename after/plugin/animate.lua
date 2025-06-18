local animate = require("mini.animate")

animate.setup({
  cursor = {
    enable = true,
    timing = animate.gen_timing.linear({ duration = 50, unit = "total" }),
  },
  scroll = {
    enable = true,
    timing = animate.gen_timing.linear({ duration = 200, unit = "total" }),
  },
  resize = {
    enable = true,
    timing = animate.gen_timing.linear({ duration = 50, unit = "total" }),
  },
  open = { enable = true },
  close = { enable = true },
})
