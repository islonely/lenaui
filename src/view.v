module lenaui

import gg
import gx

pub type View = StandardView | TabView

pub fn (mut view View) draw() {
	match mut view {
		StandardView { view.draw() }
		TabView { view.draw() }
	}
}

pub fn (mut view View) event(event &gg.Event) {
	match mut view {
		StandardView { view.event(event) }
		TabView { view.event(event) }
	}
}

pub fn (mut view View) update() {
	match mut view {
		StandardView { view.update() }
		TabView { view.update() }
	}
}

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
}

pub fn (mut view StandardView) draw() {
	view.context.draw_rect_filled(view.x, view.y, view.width, view.height, view.bg_color)
	for mut child in view.children {
		child.draw()
	}
}

pub fn (mut view StandardView) event(event &gg.Event) {
	for mut child in view.children {
		child.event(event)
	}
}

pub fn (mut view StandardView) update() {
	for mut child in view.children {
		child.update()
	}
}
