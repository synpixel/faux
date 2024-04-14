local stdio = require("@lune/stdio")

local function color(text: string, color: stdio.Color)
	return stdio.color(color) .. text .. stdio.color("reset")
end

local function style(text: string, style: stdio.Style)
	return stdio.style(style) .. text .. stdio.style("reset")
end

return {
	color = color,
	style = style,
}
