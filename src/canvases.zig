const std = @import("std");
const mem = std.mem;
const colors = @import("colors.zig");
const Color = colors.Color;
const color = colors.color;

const Canvas = struct {
    _pixels: []Color,
    _width: usize,
    _height: usize,
    _allocator: *const mem.Allocator,

    pub fn create(width: usize, height: usize, allocator: *const mem.Allocator) !Canvas {
        var pixels = try allocator.alloc(Color, height * width);
        @memset(pixels, color(0, 0, 0));
        return Canvas{
            ._pixels = pixels,
            ._width = width,
            ._height = height,
            ._allocator = allocator,
        };
    }

    pub fn deinit(self: Canvas) void {
        self._allocator.free(self._pixels);
    }

    pub fn at(self: Canvas, x: usize, y: usize) Color {
        return self._pixels[x + y * self._width];
    }
};

// // // // // // // // // // // // //
// The following is only for testing

const testing = @import("testing.zig");
const expectEqual = testing.expectEqual_;

test "Creating a canvas" {
    const c: Canvas = try Canvas.create(10, 20, &testing.allocator);
    defer c.deinit();
    try expectEqual(10, c._width);
    try expectEqual(20, c._height);
    for (0..c._width) |x| {
        for (0..c._height) |y| {
            try expectEqual(color(0, 0, 0), c.at(x, y));
        }
    }
}
