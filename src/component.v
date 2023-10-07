module lenaui

import gg

pub interface Component {
mut:
	context &gg.Context
	parent &Component
	x int
	y int
	width int
	height int
	children []&Component
	draw()
	update()
	event(event &gg.Event)
}

pub fn (mut component Component) establish_parent() {
	for mut child in component.children {
		child.parent = voidptr(component)
		child.establish_parent()
	}
}
