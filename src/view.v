module lenaui

import gg
import gx

// StandardView is the default view type.
[heap]
pub struct StandardView {
__global:
	parent   &Component = unsafe { nil }
	context  &gg.Context
	x        int
	y        int
	width    int
	height   int
	padding  Padding
	children []&Component
	bg_color gx.Color
	position Position = .relative
}

// draw draws the view and all of its children to the screen.
pub fn (mut view StandardView) draw() {
	view.context.draw_rect_filled(view.x, view.y, view.width, view.height, view.bg_color)
	for mut child in view.children {
		child.draw()
	}
}

// event handles events for the view and passes them to its children.
pub fn (mut view StandardView) event(event &gg.Event) {
	for mut child in view.children {
		child.event(event)
	}
}

// update updates the view and all of its children.
pub fn (mut view StandardView) update() {
	for mut child in view.children {
		child.update()
	}
}

// global_x returns the X position of the view added to the X position of its parent.
pub fn (mut view StandardView) global_x() int {
	return if view.parent == unsafe { nil } {
		view.x + view.padding.left
	} else {
		view.parent.global_x() + view.x + view.padding.left
	}
}

// global_y returns the Y position of the view added to the Y position of its parent.
pub fn (mut view StandardView) global_y() int {
	return if view.parent == unsafe { nil } {
		view.y + view.padding.top
	} else {
		view.parent.global_y() + view.y + view.padding.top
	}
}
