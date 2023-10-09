module lenaui

import gg
import time

struct Pos {
	x int
	y int
}

fn test_mouse_is_in_box() {
	bounding_box := gg.Rect{
		x: 50
		y: 50
		width: 50
		height: 50
	}
	to_the_left := Pos{
		x: 40
		y: 55
	}
	to_the_up := Pos{
		x: 55
		y: 40
	}
	to_the_right := Pos{
		x: 110
		y: 55
	}
	to_the_bottom := Pos{
		x: 55
		y: 110
	}
	inside := Pos{
		x: 55
		y: 55
	}
	assert mouse_is_in_box(to_the_left.x, to_the_left.y, bounding_box) == false
	assert mouse_is_in_box(to_the_up.x, to_the_up.y, bounding_box) == false
	assert mouse_is_in_box(to_the_right.x, to_the_right.y, bounding_box) == false
	assert mouse_is_in_box(to_the_bottom.x, to_the_bottom.y, bounding_box) == false
	assert mouse_is_in_box(inside.x, inside.y, bounding_box) == true
}
