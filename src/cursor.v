module lenaui

import gg
import gx
import time

// Cursor is an interface for a cursor that can be drawn
// to the screen for a text box.
pub interface Cursor {
mut:
	x int
	y int
	font_size int
	line int
	col int
	// int is the font size passed from the parent of the
	// cursor.
	draw(mut context gg.Context)
	update(mut context gg.Context)
	// set_x and set_y sets the cursor's position relative
	// to the provided x and y coordinates. X and Y should
	// will be the X and Y position of the character at the
	// cursor's position.
	set_x(int)
	set_y(int)
	set_pos(int, int)
}

// LineCursor is  a cursor with the line drawn to the left
// of the character at the cursor's position.
pub struct LineCursor {
pub mut:
	x int
	y int
__global:
	font_size int = 16
	blink     time.StopWatch // = time.new_stopwatch(auto_start: true)
	visible   bool
	color     gx.Color = gx.rgba(0x30, 0x99, 0xff, 0xff)
	line      int
	col       int
	// the rate at which the cursor switches between visible
	// and invisible.
	blink_speed time.Duration = time.millisecond * 500
	padding     Padding
}

// todo: make the blink field equal to time.new_stopwatch(auto_start: true) by default.
pub fn LineCursor.new() LineCursor {
	return LineCursor{
		blink: time.new_stopwatch(auto_start: true)
	}
}

// draw draws the cursor to the screen.
fn (mut cursor LineCursor) draw(mut context gg.Context) {
	if cursor.visible {
		cursor_width := int(f32(cursor.font_size) * 0.15)
		cursor_height := int(f32(cursor.font_size) * 1.4)
		context.draw_rect_filled(cursor.x, cursor.y, cursor_width, cursor_height, cursor.color)
	}
}

// update makes the cursor blink at the set blink speed.
fn (mut cursor LineCursor) update(mut context gg.Context) {
	if cursor.blink.elapsed() > cursor.blink_speed {
		cursor.visible = !cursor.visible
		cursor.blink.restart()
	}
}

// set_x sets the cursor's x position relative to the
// provided x coordinate.
[inline]
pub fn (mut cursor LineCursor) set_x(x int) {
	cursor.x = x - cursor.padding.right
}

// set_y sets the cursor's y position relative to the
// provided y coordinate.
[inline]
pub fn (mut cursor LineCursor) set_y(y int) {
	cursor.y = y + cursor.padding.top
}

// set_pos sets the cursor's position relative to the
// provided x and y coordinates.
[inline]
pub fn (mut cursor LineCursor) set_pos(x int, y int) {
	cursor.set_x(x)
	cursor.set_y(y)
}
