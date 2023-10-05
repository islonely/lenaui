module lenaui

import gg

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
