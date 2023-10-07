module lenaui

import gg
import gx
import math

const (
	ascii_alpha_numberic = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'.runes()
	ascii                = {
		gg.KeyCode.apostrophe:    [`'`, `"`]
		gg.KeyCode.comma:         [`,`, `<`]
		gg.KeyCode.minus:         [`-`, `_`]
		gg.KeyCode.period:        [`.`, `>`]
		gg.KeyCode.slash:         [`/`, `?`]
		gg.KeyCode._0:            [`0`, `)`]
		gg.KeyCode._1:            [`1`, `!`]
		gg.KeyCode._2:            [`2`, `@`]
		gg.KeyCode._3:            [`3`, `#`]
		gg.KeyCode._4:            [`4`, `$`]
		gg.KeyCode._5:            [`5`, `%`]
		gg.KeyCode._6:            [`6`, `^`]
		gg.KeyCode._7:            [`7`, `&`]
		gg.KeyCode._8:            [`8`, `*`]
		gg.KeyCode._9:            [`9`, `(`]
		gg.KeyCode.semicolon:     [`;`, `:`]
		gg.KeyCode.equal:         [`=`, `+`]
		gg.KeyCode.a:             [`a`, `A`]
		gg.KeyCode.b:             [`b`, `B`]
		gg.KeyCode.c:             [`c`, `C`]
		gg.KeyCode.d:             [`d`, `D`]
		gg.KeyCode.e:             [`e`, `E`]
		gg.KeyCode.f:             [`f`, `F`]
		gg.KeyCode.g:             [`g`, `G`]
		gg.KeyCode.h:             [`h`, `H`]
		gg.KeyCode.i:             [`i`, `I`]
		gg.KeyCode.j:             [`j`, `J`]
		gg.KeyCode.k:             [`k`, `K`]
		gg.KeyCode.l:             [`l`, `L`]
		gg.KeyCode.m:             [`m`, `M`]
		gg.KeyCode.n:             [`n`, `N`]
		gg.KeyCode.o:             [`o`, `O`]
		gg.KeyCode.p:             [`p`, `P`]
		gg.KeyCode.q:             [`q`, `Q`]
		gg.KeyCode.r:             [`r`, `R`]
		gg.KeyCode.s:             [`s`, `S`]
		gg.KeyCode.t:             [`t`, `T`]
		gg.KeyCode.u:             [`u`, `U`]
		gg.KeyCode.v:             [`v`, `V`]
		gg.KeyCode.w:             [`w`, `W`]
		gg.KeyCode.x:             [`x`, `X`]
		gg.KeyCode.y:             [`y`, `Y`]
		gg.KeyCode.z:             [`z`, `Z`]
		gg.KeyCode.left_bracket:  [`[`, `{`]
		gg.KeyCode.backslash:     [`\\`, `|`]
		gg.KeyCode.right_bracket: [`]`, `}`]
		gg.KeyCode.grave_accent:  [`\``, `~`]
		gg.KeyCode.tab:           [`\t`, `\t`]
		gg.KeyCode.kp_0:          [`0`, `0`]
		gg.KeyCode.kp_1:          [`1`, `1`]
		gg.KeyCode.kp_2:          [`2`, `2`]
		gg.KeyCode.kp_3:          [`3`, `3`]
		gg.KeyCode.kp_4:          [`4`, `4`]
		gg.KeyCode.kp_5:          [`5`, `5`]
		gg.KeyCode.kp_6:          [`6`, `6`]
		gg.KeyCode.kp_7:          [`7`, `7`]
		gg.KeyCode.kp_8:          [`8`, `8`]
		gg.KeyCode.kp_9:          [`9`, `9`]
		gg.KeyCode.kp_decimal:    [`.`, `.`]
		gg.KeyCode.kp_divide:     [`/`, `/`]
		gg.KeyCode.kp_multiply:   [`*`, `*`]
		gg.KeyCode.kp_subtract:   [`-`, `-`]
		gg.KeyCode.kp_add:        [`+`, `+`]
		gg.KeyCode.space:         [` `, ` `]
	}
)

// TextArea is a text box that can be edited.
[heap]
pub struct TextArea {
mut:
	children []&Component
pub mut:
	parent &Component = unsafe { nil }
__global:
	context      &gg.Context
	x            int
	y            int
	width        int
	height       int
	cursor       Cursor
	caps_lock    bool
	font_size    int      = 22
	padding      Padding  = Padding.all(10)
	text_color   gx.Color = gx.rgb(0xdd, 0xdd, 0xdd)
	bg_color     gx.Color = gx.rgb(0x22, 0x22, 0x22)
	lines        [][]rune = [][]rune{len: 1, cap: 5000}
	line_numbers struct {
	pub mut:
		x          int
		y          int
		show       bool     = true
		width      int      = 60
		text_color gx.Color = gx.rgb(0x99, 0x99, 0x99)
		bg_color   gx.Color = gx.rgba(0x25, 0x25, 0x29, 0xff)
		padding    Padding  = Padding.x(10)
	}

	tab_size               u8   = 4
	highlight_current_line bool = true
	scroll_x               int
	scroll_y               int
	scrollbar              struct {
	pub mut:
		vertical   ScrollBar
		horizontal ScrollBar
	}
}

// NewTextAreaParams is the parameters for creating a new TextArea.
[params]
pub struct NewTextAreaParams {
__global:
	width   int         [required]
	height  int         [required]
	context &gg.Context [required]
	cursor  Cursor      [required]
	text    string
}

// new creates a TextArea with the given parameters.
pub fn TextArea.new(params NewTextAreaParams) &TextArea {
	mut textarea := &TextArea{
		width: params.width
		height: params.height
		context: params.context
		cursor: params.cursor
	}
	textarea.set_text(params.text)
	textarea.update_cursor_pos()
	textarea.update_line_numbers()
	textarea.scrollbar = struct {
		vertical: ScrollBar.new(textarea, .vertical)
		horizontal: ScrollBar.new(textarea, .horizontal)
	}
	return textarea
}

// draw draws the TextArea to the given context.
pub fn (mut textarea TextArea) draw() {
	textarea.context.set_text_cfg(gx.TextCfg{
		size: textarea.font_size
		mono: true
	})
	textarea.context.draw_rect_filled(textarea.x, textarea.y, textarea.width, textarea.height,
		textarea.bg_color)

	for i, line in textarea.lines {
		if textarea.highlight_current_line && i == textarea.cursor.line {
			textarea.context.draw_rect_filled(textarea.x, textarea.y - textarea.scroll_y +
				textarea.padding.top + i * textarea.font_size, textarea.width, textarea.font_size,
				gx.rgba(0x33, 0x33, 0x33, 0x99))
		}
		if textarea.line_numbers.show {
			textarea.context.draw_text(textarea.x - textarea.scroll_x + textarea.padding.left +
				textarea.line_numbers.width, textarea.y - textarea.scroll_y + textarea.padding.top +
				i * textarea.font_size, line.string().replace('\t', ' '.repeat(textarea.tab_size)),
				color: textarea.text_color
				size: textarea.font_size
			)
			line_number_x := textarea.line_numbers.x + textarea.line_numbers.width / 2 - text_width(textarea.context,
				(i + 1).str()) / 2
			line_number_y := textarea.line_numbers.y - textarea.scroll_y + textarea.padding.top +
				i * textarea.font_size
			textarea.context.draw_rect_filled(textarea.line_numbers.x, line_number_y - textarea.line_numbers.padding.top,
				text_width(textarea.context, (textarea.lines.len + 1).str()) +
				textarea.line_numbers.padding.left + textarea.line_numbers.padding.right,
				textarea.font_size + textarea.line_numbers.padding.top +
				textarea.line_numbers.padding.bottom, textarea.line_numbers.bg_color)
			textarea.context.draw_text(line_number_x, line_number_y, (i + 1).str(),
				color: textarea.line_numbers.text_color
				size: textarea.font_size
			)
		} else {
			textarea.context.draw_text(textarea.x + textarea.padding.left, textarea.y +
				textarea.padding.top + i * textarea.font_size, line.string(),
				color: textarea.text_color
				size: textarea.font_size
			)
		}
	}
	textarea.cursor.draw(mut textarea.context)
	textarea.scrollbar.vertical.draw(mut textarea.context)
	textarea.scrollbar.horizontal.draw(mut textarea.context)

	draw_debug_rect(mut textarea.context, -textarea.scroll_x, -textarea.scroll_y, textarea.content_width(),
		textarea.content_height(), gx.red)
}

// update updates the TextArea
pub fn (mut textarea TextArea) update() {
	textarea.cursor.update(mut textarea.context)
	textarea.update_cursor_pos()
	textarea.update_line_numbers()
}

// event handles keystrokes for the TextArea.
pub fn (mut textarea TextArea) event(event &gg.Event) {
	textarea.scrollbar.vertical.event(event, textarea.context.key_modifiers)
	textarea.scrollbar.horizontal.event(event, textarea.context.key_modifiers)

	if event.typ == .key_up {
		if event.key_code == .caps_lock {
			textarea.caps_lock = !textarea.caps_lock
		}
		return
	}

	if event.typ == .key_down {
		// textarea.update_line_numbers()

		// stop cursor blinking while typing
		if mut textarea.cursor is LineCursor {
			textarea.cursor.visible = true
			textarea.cursor.blink.restart()
		}

		if event.key_code in lenaui.ascii {
			if !textarea.context.key_modifiers.has(.ctrl)
				&& ((textarea.context.key_modifiers.has(.shift) && !textarea.caps_lock)
				|| (textarea.caps_lock && !textarea.context.key_modifiers.has(.shift))) {
				textarea.lines[textarea.cursor.line].insert(textarea.cursor.col, lenaui.ascii[event.key_code][1]) // [1] for captial letters
				textarea.move_cursor_right()
			} else if !textarea.context.key_modifiers.has(.ctrl)
				&& ((!textarea.caps_lock && !textarea.context.key_modifiers.has(.shift))
				|| (textarea.caps_lock && textarea.context.key_modifiers.has(.shift))) {
				textarea.lines[textarea.cursor.line].insert(textarea.cursor.col, lenaui.ascii[event.key_code][0]) // [0] for lowercase letters
				textarea.move_cursor_right()
			}
			return
		}

		if event.key_code == .backspace {
			if textarea.cursor.col > 0 {
				textarea.lines[textarea.cursor.line].delete(textarea.cursor.col - 1)
				textarea.move_cursor_left()
			} else if textarea.cursor.line > 0 {
				textarea.cursor.line -= 1
				textarea.cursor.col = textarea.lines[textarea.cursor.line].len
				textarea.lines[textarea.cursor.line] << textarea.lines[textarea.cursor.line + 1]
				textarea.lines.delete(textarea.cursor.line + 1)
			}
			return
		}
		if event.key_code == .delete {
			if textarea.cursor.col < textarea.lines[textarea.cursor.line].len {
				textarea.lines[textarea.cursor.line].delete(textarea.cursor.col)
			} else if textarea.cursor.line < textarea.lines.len - 1 {
				textarea.lines[textarea.cursor.line] << textarea.lines[textarea.cursor.line + 1]
				textarea.lines.delete(textarea.cursor.line + 1)
			}
			return
		}

		if event.key_code == .enter {
			textarea.lines.insert(textarea.cursor.line + 1, textarea.lines[textarea.cursor.line][textarea.cursor.col..])
			textarea.lines[textarea.cursor.line] = textarea.lines[textarea.cursor.line][..textarea.cursor.col]
			textarea.cursor.line++
			textarea.cursor.col = 0
			return
		}

		if event.key_code == .up {
			textarea.move_cursor_up()
			return
		}
		if event.key_code == .down {
			textarea.move_cursor_down()
			return
		}
		if event.key_code == .right {
			if textarea.context.key_modifiers.has(.ctrl) {
				if textarea.cursor.col == textarea.lines[textarea.cursor.line].len {
					textarea.move_cursor_right()
					return
				}

				mut started_with_non_alpha_numeric := if textarea.lines[textarea.cursor.line].len > 0 {
					textarea.lines[textarea.cursor.line][textarea.cursor.col] !in lenaui.ascii_alpha_numberic
				} else {
					false
				}
				for i in textarea.cursor.col .. textarea.lines[textarea.cursor.line].len {
					if i == textarea.lines[textarea.cursor.line].len - 1 {
						textarea.cursor.col++
						break
					}
					if started_with_non_alpha_numeric
						&& textarea.lines[textarea.cursor.line][i] !in lenaui.ascii_alpha_numberic {
						started_with_non_alpha_numeric = false
						textarea.cursor.col++
						continue
					}
					if textarea.lines[textarea.cursor.line][i] !in lenaui.ascii_alpha_numberic {
						break
					}
					textarea.cursor.col++
				}
				textarea.update_cursor_pos()
			} else {
				textarea.move_cursor_right()
			}
			return
		}
		if event.key_code == .left {
			if textarea.context.key_modifiers.has(.ctrl) {
				if textarea.cursor.col == 0 {
					textarea.move_cursor_left()
					return
				}

				mut started_with_non_alpha_numeric := if textarea.cursor.col > 0 {
					textarea.lines[textarea.cursor.line][textarea.cursor.col - 1] !in lenaui.ascii_alpha_numberic
				} else {
					false
				}

				for i := textarea.cursor.col; i > 0; i-- {
					if i == 0 {
						textarea.cursor.col--
						break
					}
					if started_with_non_alpha_numeric
						&& textarea.lines[textarea.cursor.line][i - 1] !in lenaui.ascii_alpha_numberic {
						started_with_non_alpha_numeric = false
						textarea.cursor.col--
						continue
					}
					if textarea.lines[textarea.cursor.line][i - 1] !in lenaui.ascii_alpha_numberic {
						break
					}
					textarea.cursor.col--
				}

				textarea.update_cursor_pos()
			} else {
				textarea.move_cursor_left()
			}
			return
		}
		if event.key_code == .end {
			textarea.cursor.col = textarea.lines[textarea.cursor.line].len
			return
		}
		if event.key_code == .home {
			textarea.cursor.col = 0
			return
		}
	}
}

// content_height returns the height of the TextArea's content.
[inline]
pub fn (textarea TextArea) content_height() int {
	content_height := textarea.lines.len * textarea.font_size + textarea.padding.top +
		textarea.padding.bottom
	return math.max(content_height, textarea.height)
}

// content_width returns the width of the TextArea's content.
pub fn (textarea TextArea) content_width() int {
	mut max_width := 0
	for line in textarea.lines {
		max_width = math.max(max_width, text_width(textarea.context, line.string()))
	}
	max_width += textarea.padding.left + textarea.padding.right
	return math.max(max_width, textarea.width)
}

// update_line_numbers updates the width of the line number container to adjust for the number of
// lines in the TextArea.
[inline]
fn (mut textarea TextArea) update_line_numbers() {
	width := text_width(textarea.context, (textarea.lines.len + 1).str()) +
		textarea.line_numbers.padding.left + textarea.line_numbers.padding.right
	textarea.line_numbers.width = (width / 10) * 10
}

// update_cursor_pos moves the cursor to the correct position based on the cursor's line and column.
[inline]
fn (mut textarea TextArea) update_cursor_pos() {
	textarea.update_cursor_x()
	textarea.update_cursor_y()
}

// update_cursor_x moves the cursor to the correct x position based on the cursor's column.
fn (mut textarea TextArea) update_cursor_x() {
	line := textarea.lines[textarea.cursor.line]

	// cursor_x := if line.len > 0 {
	// 	textarea.x + textarea.padding.left + textarea.line_numbers.width +
	// 		(textarea.cursor.col * text_width(textarea.context, line.string()) / line.len)
	// } else {
	// 	textarea.x + textarea.padding.left + textarea.line_numbers.width
	// }
	mut cursor_x := textarea.x - textarea.scroll_x + textarea.padding.left +
		textarea.line_numbers.width
	for i := 0; i < textarea.cursor.col; i++ {
		if line[i] == `\t` {
			tab_width := text_width(textarea.context, ' '.repeat(textarea.tab_size))
			cursor_x += tab_width - (cursor_x % tab_width)
		} else {
			cursor_x += text_width(textarea.context, line[i].str())
		}
	}
	textarea.cursor.set_x(cursor_x)
}

// update_cursor_y moves the cursor to the correct y position based on the cursor's line.
fn (mut textarea TextArea) update_cursor_y() {
	textarea.cursor.set_y(textarea.y - textarea.scroll_y + textarea.padding.top +
		textarea.cursor.line * textarea.font_size)
}

// move_cursor_down moves the cursor down one line.
fn (mut textarea TextArea) move_cursor_down() {
	if textarea.cursor.line < textarea.lines.len - 1 {
		textarea.cursor.line++
		textarea.cursor.col = math.min(textarea.cursor.col, textarea.lines[textarea.cursor.line].len)
	} else {
		textarea.cursor.col = textarea.lines[textarea.cursor.line].len
	}
	textarea.update_cursor_pos()
}

// move_cursor_up moves the cursor up one line.
fn (mut textarea TextArea) move_cursor_up() {
	if textarea.cursor.line > 0 {
		textarea.cursor.line--
		textarea.cursor.col = math.min(textarea.cursor.col, textarea.lines[textarea.cursor.line].len)
	} else {
		textarea.cursor.col = 0
	}
	textarea.update_cursor_pos()
}

// move_cursor_right moves the cursor right one column.
fn (mut textarea TextArea) move_cursor_right() {
	line := textarea.lines[textarea.cursor.line]
	if textarea.cursor.col < line.len {
		textarea.cursor.col++
	} else if textarea.cursor.line < textarea.lines.len - 1 {
		textarea.cursor.col = 0
		textarea.cursor.line++
	}
	textarea.update_cursor_pos()
}

// move_cursor_left moves the cursor left one column.
fn (mut textarea TextArea) move_cursor_left() {
	if textarea.cursor.col > 0 {
		textarea.cursor.col--
	} else if textarea.cursor.line > 0 {
		textarea.cursor.line--
		textarea.cursor.col = textarea.lines[textarea.cursor.line].len
	}
	textarea.update_cursor_pos()
}

// set_text sets the text of the TextArea.
pub fn (mut textarea TextArea) set_text(text string) {
	new_lines := text.split_into_lines()
	textarea.lines = [][]rune{cap: math.max(new_lines.len, 5000)}
	for line in new_lines {
		textarea.lines << line.runes()
	}
}
