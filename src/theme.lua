local Button = require 'lib.node.control.button'
local Label  = require 'lib.node.control.label'

Label.setDefaultTheme({ color = { 1, 1, 1, 1 } })
Button.setDefaultTheme({ background = { 1, 1, 0, 0.5 } })
Button.setDefaultHoverTheme({ background = { 0, 1, 0, 0.5 } })
