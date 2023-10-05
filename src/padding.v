module lenaui

// Padding is a struct that represents the padding of a widget.
// It is measured in pixels.
pub struct Padding {
__global:
	top    int
	right  int
	bottom int
	left   int
}

// Padding.x returns a Padding struct with the given x_padding.
[inline]
pub fn Padding.x(x_padding int) Padding {
	return Padding{
		top: 0
		right: x_padding
		bottom: 0
		left: x_padding
	}
}

// Padding.y returns a Padding struct with the given y_padding.
[inline]
pub fn Padding.y(y_padding int) Padding {
	return Padding{
		top: y_padding
		right: 0
		bottom: y_padding
		left: 0
	}
}

// Padding.xy returns a Padding struct with the given x_padding and y_padding.
[inline]
pub fn Padding.xy(x_padding int, y_padding int) Padding {
	return Padding{
		top: y_padding
		right: x_padding
		bottom: y_padding
		left: x_padding
	}
}

// Padding.all returns a Padding struct with the given padding.
[inline]
pub fn Padding.all(padding int) Padding {
	return Padding{
		top: padding
		right: padding
		bottom: padding
		left: padding
	}
}
