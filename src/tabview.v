module lenaui

import gg
import gx

// TabView is a component that can contain multiple TabComponents.
pub struct TabView {
mut:
	children []&Component
__global:
	context &gg.Context   [required]
	parent  &Component = unsafe { nil }
	x       int
	y       int
	width   int
	height  int
	tabs    []&Tab
	padding Padding
	tab     struct {
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

		child_x := tabview.x + tabview.padding.left
		child_y := tabview.y + tabview.padding.top + tab_height + tabview.tab.margin.y()
		child_width := tabview.width - tabview.padding.left - tabview.padding.right
		child_height := tabview.height - tabview.padding.top - tabview.padding.bottom
		tab.view.width = child_width
		tab.view.height = child_height
		tab.view.x = child_x
		tab.view.y = child_y

		if i == tabview.tab.index {
			tab.view.draw()
		}

		{ // draw tabs

			tabview.context.draw_rounded_rect_filled(tab_x, tab_y, tab_width, tab_height,
				tabview.tab.radius, tab_color)
			tabview.context.draw_text(tab_x + tabview.tab.padding.left, tab_y +
				tabview.tab.padding.top, tab.short_name,
				color: tabview.tab.text_color
				bold: if i == tabview.tab.index { true } else { false }
				size: tabview.tab.font_size
			)
			total_tab_width += tab_width + tabview.tab.margin.right + tabview.tab.margin.left
		}
	}
}

pub fn (mut tabview TabView) event(event &gg.Event) {
	for mut tab in tabview.tabs {
		tab.view.event(event)
	}
}

pub fn (mut tabview TabView) update() {
	for mut tab in tabview.tabs {
		tab.view.update()
	}
}

// TabComponent is a component that can be added to a TabView.
pub interface TabComponent {
	Component
mut:
	full_tab_name string
	short_tab_name string
}

pub struct Tab {
__global:
	full_name  string
	short_name string
	view       &View
}
