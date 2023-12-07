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

    pub fn pixel_at(self: Canvas, x: usize, y: usize) Color {
        return self._pixels[x + y * self._width];
    }

    pub fn write_pixel(self: Canvas, x: usize, y: usize, c: Color) void {
        self._pixels[x + y * self._width] = c;
    }

    pub fn to_ppm(self: Canvas, writer: anytype) !void {
        _ = try writer.writeAll("P3\n");
        try writer.print("{d} {d}\n", .{ self._width, self._height });
        _ = try writer.writeAll("255\n");
    }
};

fn canvas(width: usize, height: usize, allocator: *const mem.Allocator) !Canvas {
    return try Canvas.create(width, height, allocator);
}

// // // // // // // // // // // // //
// The following is only for testing

const testing = @import("testing.zig");
const expectEqual = testing.expectEqual_;
const expectEqualStrings = testing.expectEqualStrings;
const ArrayList = std.ArrayList;

/// Select lines from...to of the given slice, and return only that part (without a trailing newline)
fn stringLines(slice: []const u8, from: usize, to: usize) []const u8 {
    var seenNewlines: usize = 0;
    var i: ?usize = null;
    var j: usize = 0;
    while (j < slice.len) {
        if (i == null and seenNewlines + 1 == from) i = j;
        if (slice[j] == '\n') seenNewlines += 1;
        if (seenNewlines == to) break;
        j += 1;
    }
    return slice[i.?..j];
}

test "Creating a canvas" {
    const c = try canvas(10, 20, &testing.allocator);
    defer c.deinit();
    try expectEqual(10, c._width);
    try expectEqual(20, c._height);
    for (0..c._width) |x| {
        for (0..c._height) |y| {
            try expectEqual(color(0, 0, 0), c.pixel_at(x, y));
        }
    }
}

test "Writing pixels to a canvas" {
    const c = try canvas(10, 20, &testing.allocator);
    defer c.deinit();
    const red = color(1, 0, 0);
    c.write_pixel(2, 3, red);
    try expectEqual(red, c.pixel_at(2, 3));
}

test "Constructing the PPM header" {
    const c = try canvas(5, 3, &testing.allocator);
    defer c.deinit();
    var ppm = ArrayList(u8).init(testing.allocator);
    defer ppm.deinit();
    try c.to_ppm(ppm.writer());
    try expectEqualStrings(
        \\P3
        \\5 3
        \\255
    , stringLines(ppm.items, 1, 3));
}
