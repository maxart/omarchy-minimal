local active_border_color = "#878787"
local inactive_border_color = "#262626"

hl.config({
  general = {
    col = {
      active_border = active_border_color,
      inactive_border = inactive_border_color,
    },
  },

  group = {
    col = {
      border_active = active_border_color,
      border_inactive = inactive_border_color,
    },
  },
})

-- Keep group tabs aligned with the focus accent.
hl.config({
  group = {
    groupbar = {
      col = { active = "#d3d3d3", inactive = "#191919" },
      text_color = "#000000", text_color_inactive = "#e7e9ea",
    },
  },
})
