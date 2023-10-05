module lenaui

import gg
import gx

// ScrollBarParent is an object that can be scrolled by a ScrollBar.
// ScrollBarParents must be heap initialized with `&Type{}`.
pub interface ScrollBarParent {
	x int
	y int
	width int
	height int
	content_width() int
	content_height() int
mut:
	scroll_x int
	scroll_y int
}

// ScrollBarOrientation is the orientation of a ScrollBar. Vertical scrolls up
// and down, horizontal scrolls left and right.
pub enum ScrollBarOrientation {
	vertical
	horizontal
}

// ScrollBar is a scroll bar.
pub struct ScrollBar {
__global:
	parent          &ScrollBarParent = unsafe { nil }
	x               int
	y               int
	width           int
	height          int
	container_color gx.Color = gx.rgba(0, 0, 0, 0)
	orientation     ScrollBarOrientation
	// when the content of the parent fits on the screen the scroll bar is
	// not drawn if this is true
	hide_when_not_needed bool = true
	dragging_scrollbar   bool
	bar                  struct {
	__global:
		x      int
		y      int
		width  int
		height int
		radius int      = 10
		color  gx.Color = gx.rgba(0xbb, 0xbb, 0xbb, 0xcc)
	}
}

pub fn ScrollBar.new(parent &ScrollBarParent, orientation ScrollBarOrientation) ScrollBar {
	default_bar_size := 5
	mut scrollbar := if orientation == .vertical {
		ScrollBar{
			parent: unsafe { parent }
			x: parent.x + parent.width - default_bar_size
			y: parent.y
			orientation: orientation
			width: default_bar_size
			height: parent.height
			bar: struct {
				x: parent.x + parent.width - default_bar_size
				y: parent.y
				width: default_bar_size
				height: parent.height * parent.height / parent.content_height()
			}
		}
	} else {
		ScrollBar{
			parent: unsafe { parent }
			x: parent.x
			y: parent.y + parent.height - default_bar_size
			orientation: orientation
			width: parent.width
			height: default_bar_size
			bar: struct {
				x: parent.x
				y: parent.y + parent.height - default_bar_size
				width: parent.width * parent.width / parent.content_width()
				height: default_bar_size
			}
		}
	}
	return scrollbar
}

pub fn (mut scrollbar ScrollBar) update() {
	if scrollbar.orientation == .vertical {
		scrollbar.bar.height = scrollbar.parent.height * scrollbar.parent.height / scrollbar.parent.content_height()
		if scrollbar.parent.content_height() == scrollbar.parent.height {
			scrollbar.bar.y = scrollbar.parent.y
		} else {
			scrollbar.bar.y = scrollbar.parent.y +(scrollbar.parent.height - scrollbar.bar.height) * scrollbar.parent.scroll_y / (scrollbar.parent.content_height() - scrollbar.parent.height)
		}
	} else {
		scrollbar.bar.width = scrollbar.parent.width * scrollbar.parent.width / scrollbar.parent.content_width()
		if scrollbar.parent.content_width() == scrollbar.parent.width {
			scrollbar.bar.x = scrollbar.parent.x
		} else {
			scrollbar.bar.x = scrollbar.parent.x +(scrollbar.parent.width - scrollbar.bar.width) * scrollbar.parent.scroll_x / (scrollbar.parent.content_width() - scrollbar.parent.width)
		}
	}
}

// event handles events for the scroll bar.
pub fn (mut scrollbar ScrollBar) event(event &gg.Event, modifiers gg.Modifier) {
	if event.typ == .mouse_down {
		mouse_in_scroll_bar := event.mouse_x >= scrollbar.bar.x
			&& event.mouse_x <= scrollbar.bar.x + scrollbar.bar.width
			&& event.mouse_y >= scrollbar.bar.y
			&& event.mouse_y <= scrollbar.bar.y + scrollbar.bar.height
		if mouse_in_scroll_bar {
			scrollbar.dragging_scrollbar = true
		}
	} else if event.typ == .mouse_up {
		scrollbar.dragging_scrollbar = false
	} else if event.typ == .mouse_move {
		if scrollbar.dragging_scrollbar {
			if scrollbar.orientation == .vertical {
				scroll_min_reached := scrollbar.parent.scroll_y <= 0 && event.mouse_dy < 0
				scroll_max_reached :=
					scrollbar.parent.content_height() - scrollbar.parent.scroll_y < scrollbar.parent.height
					&& event.mouse_dy > 0
				if scroll_min_reached || scroll_max_reached {
					return
				}
				scrollbar.parent.scroll_y += int(event.mouse_dy * scrollbar.parent.content_height() / scrollbar.parent.height)
			} else {
				scroll_min_reached := scrollbar.parent.scroll_x <= 0 && event.mouse_dx < 0
				scroll_max_reached :=
					scrollbar.parent.content_width() - scrollbar.parent.scroll_x < scrollbar.parent.width
					&& event.mouse_dx > 0
				if scroll_min_reached || scroll_max_reached {
					return
				}
				scrollbar.parent.scroll_x += int(event.mouse_dx * scrollbar.parent.content_width() / scrollbar.parent.width)
			}
		}
	} else if event.typ == .mouse_scroll {
		// clamp scroll values
		if scrollbar.parent.scroll_x < 0 {
			scrollbar.parent.scroll_x = 0
		} else if scrollbar.parent.scroll_x > scrollbar.parent.content_width() - scrollbar.parent.width {
			scrollbar.parent.scroll_x = scrollbar.parent.content_width() - scrollbar.parent.width
		}
		if scrollbar.parent.scroll_y < 0 {
			scrollbar.parent.scroll_y = 0
		} else if scrollbar.parent.scroll_y > scrollbar.parent.content_height() - scrollbar.parent.height {
			scrollbar.parent.scroll_y = scrollbar.parent.content_height() - scrollbar.parent.height
		}

		if modifiers.has(.shift) {
			// scroll left/right on shift + scroll wheel
			scroll_min_reached := scrollbar.parent.scroll_x == 0 && event.scroll_x > 0
			scroll_max_reached :=
				scrollbar.parent.content_width() - scrollbar.parent.scroll_x < scrollbar.parent.width
				&& event.scroll_x < 0
			if scroll_min_reached || scroll_max_reached {
				return
			}
			scrollbar.parent.scroll_x -= int(event.scroll_y * 10)
		} else {
			// scroll up/down on scroll wheel
			scroll_min_reached := scrollbar.parent.scroll_y == 0 && event.scroll_y > 0
			scroll_max_reached :=
				scrollbar.parent.content_height() - scrollbar.parent.scroll_y < scrollbar.parent.height
				&& event.scroll_y < 0
			if scroll_min_reached || scroll_max_reached {
				return
			}
			scrollbar.parent.scroll_y -= int(event.scroll_y * 10)
		}
	}

	scrollbar.update()
}

// draw draws the scroll bar to the context.
pub fn (mut scrollbar ScrollBar) draw(mut context gg.Context) {
	// return if the scrollbar can't scroll
	if scrollbar.hide_when_not_needed {
		match scrollbar.orientation {
			.vertical {
				if scrollbar.parent.content_height() <= scrollbar.parent.height {
					return
				}
			}
			.horizontal {
				if scrollbar.parent.content_width() <= scrollbar.parent.width {
					return
				}
			}
		}
	}
	// bar container
	context.draw_rect_filled(scrollbar.x, scrollbar.y, scrollbar.width, scrollbar.height,
		scrollbar.container_color)
	// scrolly bar
	context.draw_rounded_rect_filled(scrollbar.bar.x, scrollbar.bar.y, scrollbar.bar.width,
		scrollbar.bar.height, scrollbar.bar.radius, scrollbar.bar.color)
}
