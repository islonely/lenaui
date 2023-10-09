module lenaui

import gg
import gx

// TabView is a component that can contain multiple TabComponents.
pub struct TabView {
mut:
	children []&Component
__global:
	context  &gg.Context   [required]
	parent   ?&Component = unsafe { nil }
	x        int
	y        int
	width    int
	height   int
	tabs     []&Tab
	padding  Padding
	position Position = .relative
	tab      struct {
	__global:
		text_color           gx.Color = gx.rgb(0xff, 0xff, 0xff)
		bg_color             gx.Color = gx.rgb(0x1a, 0x1a, 0x1a)
		active_bg_color      gx.Color = gx.rgb(0x2f, 0x3a, 0x4a)
		slide_down_on_active bool     = true
		index                int
		margin               Padding
		padding              Padding = Padding.all(10)
		font_size            int     = 18
		radius               int
	}
}

// push_tab sets the parent of the Tab to the TabView and adds the Tab to the TabView.
pub fn (mut tabview TabView) push_tab(tab &Tab) {
	tabview.tabs << tab
	tabview.tabs[tabview.tabs.len - 1].view.parent = unsafe { tabview }
	if tab.view.position == .relative {
		tabview.tabs[tabview.tabs.len - 1].view.x += tabview.x + tabview.padding.left
		tabview.tabs[tabview.tabs.len - 1].view.y += tabview.y + tabview.get_tab_height()
	}
}

// global_x returns the X position of the TabView relative to the window.
pub fn (tabview TabView) global_x() int {
	return if mut parent := tabview.parent {
		parent.global_x() + tabview.x + tabview.padding.left
	} else {
		tabview.x + tabview.padding.left
	}
}

// global_y returns the Y position of the TabView relative to the window.
pub fn (tabview TabView) global_y() int {
	return if mut parent := tabview.parent {
		parent.global_y() + tabview.y + tabview.padding.top
	} else {
		tabview.y + tabview.padding.top
	}
}

// get_tab_height returns the height of the tabs including padding and margin.
pub fn (tabview TabView) get_tab_height() int {
	if tabview.tabs.len == 0 {
		return 0
	}
	return tabview.context.text_height(tabview.tabs[0].short_name) + tabview.tab.padding.y() +
		tabview.tab.margin.y()
}

// get_tab_width returns the width of all the tabs combined including padding and margin.
pub fn (tabview TabView) get_tab_width() int {
	mut total_tab_width := 0
	for tab in tabview.tabs {
		total_tab_width += text_width(tabview.context, tab.short_name) + tabview.tab.padding.x() +
			tabview.tab.margin.x()
	}
	return total_tab_width
}

// draw draws the TabView and all of its children.
pub fn (mut tabview TabView) draw() {
	mut total_tab_width := 0
	for i, mut tab in tabview.tabs {
		tabview.context.set_text_cfg(size: tabview.tab.font_size, color: tabview.tab.text_color)
		tab_width := text_width(tabview.context, tab.short_name) + tabview.tab.padding.x()
		tab_height := tabview.context.text_height(tab.short_name) + tabview.tab.padding.y()
		tab_x := tabview.x + total_tab_width
		tab_y := tabview.y + tabview.tab.margin.top
		tab_color := if i == tabview.tab.index {
			tabview.tab.active_bg_color
		} else {
			tabview.tab.bg_color
		}

		if i == tabview.tab.index {
			tab.view.draw()
		}

		tabview.context.draw_rounded_rect_filled(tab_x, tab_y, tab_width, tab_height,
			tabview.tab.radius, tab_color)
		tabview.context.draw_text(tab_x + tabview.tab.padding.left, tab_y + tabview.tab.padding.top,
			tab.short_name,
			color: tabview.tab.text_color
			bold: if i == tabview.tab.index { true } else { false }
			size: tabview.tab.font_size
		)
		total_tab_width += tab_width + tabview.tab.margin.right + tabview.tab.margin.left

		draw_debug_rect(mut tabview.context, tab_x, tab_y, tab_width, tab_height, gx.green)
	}
}

// event handles events for the TabView and all of its children.
pub fn (mut tabview TabView) event(event &gg.Event) {
	if event.typ == .mouse_down {
		mut cur_tab_x := tabview.x
		for i, tab in tabview.tabs {
			bounding_box := gg.Rect{
				x: cur_tab_x
				y: tabview.y
				width: text_width(tabview.context, tab.short_name) + tabview.tab.padding.x()
				height: tabview.context.text_height(tab.short_name) + tabview.tab.padding.y()
			}
			cur_tab_x += int(bounding_box.width + tabview.tab.margin.x())

			if mouse_is_in_box(event.mouse_x, event.mouse_y, bounding_box) {
				tabview.tab.index = i
			}
		}
	}

	for mut tab in tabview.tabs {
		tab.view.event(event)
	}
}

// update updates the TabView and all of its children.
pub fn (mut tabview TabView) update() {
	for mut tab in tabview.tabs {
		tab.view.x = tabview.x + tabview.padding.left
		tab.view.y = tabview.y + tabview.get_tab_height()
		tab.view.update()
	}
}

// Tab is a struct that contains information about a TabComponent.
pub struct Tab {
__global:
	full_name  string
	short_name string
	view       &Component
}
