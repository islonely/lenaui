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
	position Position
	padding Padding
	draw()
	update()
	event(event &gg.Event)
	global_x() int
	global_y() int
}

pub fn (mut component Component) push_child(child &Component) {
	component.children << child
	component.children[component.children.len - 1].parent = unsafe { component }
	// if child.position == .relative {
	// 	component.children[component.children.len - 1].x += component.x + component.padding.left
	// 	component.children[component.children.len - 1].y += component.y + component.padding.top
	// }
}

// Position is the position of a component. Relative means that the component is
// positioned relative to its parent component. Absolute means that the component
// is positioned relative to the window.
pub enum Position {
	relative
	absolute
}
