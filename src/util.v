module lenaui

import gg
import gx

const debug_line_thickness = 2

// text_width returns the width of the given text in pixels.
// Note: gg.Context.text_width does not seem to be working properly.
pub fn text_width(context &gg.Context, text string) int {
	$if windows {
		if context.native_rendering {
			return context.text_width(text)
		}
	}
	adv := context.ft.fons.text_bounds(0, 0, text, &f32(0))
	return int(adv / context.scale)
}

// draw_debug_rect draws a scissor rectangle to visualize a container.
[if debug]
pub fn draw_debug_rect(mut context gg.Context, x int, y int, w int, h int, color gx.Color) {
	context.draw_line_with_config(x, y, x + w, y,
		color: color
		thickness: lenaui.debug_line_thickness
	)
	context.draw_line_with_config(x + w, y, x + w, y + h,
		color: color
		thickness: lenaui.debug_line_thickness
	)
	context.draw_line_with_config(x + w, y + h, x, y + h,
		color: color
		thickness: lenaui.debug_line_thickness
	)
	context.draw_line_with_config(x, y + h, x, y,
		color: color
		thickness: lenaui.debug_line_thickness
	)
	context.draw_line_with_config(x, y, x + w, y + h,
		color: color
		thickness: lenaui.debug_line_thickness
	)
	context.draw_line_with_config(x + w, y, x, y + h,
		color: color
		thickness: lenaui.debug_line_thickness
	)
}
