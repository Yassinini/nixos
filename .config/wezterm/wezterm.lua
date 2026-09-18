local wezterm = require 'wezterm'
local config = {}

-- Font settings
config.font = wezterm.font('DejaVu Sans Mono')
config.font_size = 11.25
config.line_height = 1.25 -- Increase this if it still feels crushed

-- Transparency and Decorations
config.window_background_opacity = 0.75
config.window_decorations = "NONE"

-- Tab Bar: Disable completely
config.enable_tab_bar = false

-- Colors: Choose a softer scheme (e.g., Catppuccin Mocha)
config.color_scheme = 'Nord'

return config
