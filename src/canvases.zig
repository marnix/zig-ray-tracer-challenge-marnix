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

    pub fn to_ppm(self: Canvas, w: anytype) !void {
        var buf = std.io.bufferedWriter(w);
        defer buf.flush() catch {};
        var writer = buf.writer();

        // the format
        _ = try writer.writeAll("P3\n");
        // the size
        try writer.print("{d} {d}\n", .{ self._width, self._height });
        const maxPixelValue = floatToValue(1);
        try writer.print("{d}\n", .{maxPixelValue});

        for (0..self._height) |y| {
            var lineLength: usize = 0;
            var separator: []const u8 = "";
            for (0..self._width) |x| {
                const c = self.pixel_at(x, y);
                for ([_]colors.Float{ c.red, c.green, c.blue }) |f| {
                    const n = floatToValue(f);

                    // insert a newline if the writer.print() below would go beyond 70 characters
                    const numberLength = stringLengthInBase10Of(n);
                    if (lineLength + separator.len + numberLength > 70) {
                        try writer.writeAll("\n");
                        lineLength = 0;
                        separator = "";
                    }

                    try writer.print("{s}{d}", .{ separator, n });
                    lineLength += separator.len + numberLength;
                    separator = " ";
                }
            }
            try writer.writeAll("\n");
        }
    }

    fn floatToValue(f: colors.Float) u8 {
        return Color.asInt(u8, 255, f);
    }

    fn stringLengthInBase10Of(n: usize) usize {
        if (n == 0) {
            return 1;
        } else {
            const log10n = @log10(@as(f16, @floatFromInt(n)));
            return 1 + @as(usize, @intFromFloat(@trunc(log10n)));
        }
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

/// Select lines from...to (inclusive) of the given slice, and return only that part (without a trailing newline)
fn stringLines(slice: []const u8, from: usize, to: usize) []const u8 {
    std.debug.assert(from <= to);
    var currentLineNumber: usize = 1;
    var i: ?usize = null;
    var j: usize = 0;
    while (j < slice.len) {
        if (i == null and currentLineNumber == from) i = j;
        if (slice[j] == '\n') currentLineNumber += 1;
        if (currentLineNumber == to + 1) break;
        j += 1;
    } else {
        if (currentLineNumber < to) {
            std.log.err(
                "Found only {d} lines, expected at least {d}, in slice <<<\n{s}>>>\n",
                .{ currentLineNumber, to, slice },
            );
            return "NOTHING TO SEE HERE";
        }
    }
    std.debug.assert(i != null);
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

test "Constructing the PPM pixel data" {
    const c = try canvas(5, 3, &testing.allocator);
    defer c.deinit();

    const c1 = color(1.5, 0, 0);
    const c2 = color(0, 0.5, 0);
    const c3 = color(-0.5, 0, 1);
    c.write_pixel(0, 0, c1);
    c.write_pixel(2, 1, c2);
    c.write_pixel(4, 2, c3);
    var ppm = ArrayList(u8).init(testing.allocator);
    defer ppm.deinit();
    try c.to_ppm(ppm.writer());

    try expectEqualStrings(
        \\255 0 0 0 0 0 0 0 0 0 0 0 0 0 0
        \\0 0 0 0 0 0 0 128 0 0 0 0 0 0 0
        \\0 0 0 0 0 0 0 0 0 0 0 0 0 0 255
    , stringLines(ppm.items, 4, 6));
}

test "Splitting long lines in PPM files" {
    const c = try canvas(10, 2, &testing.allocator);
    defer c.deinit();
    for (0..c._width) |x| {
        for (0..c._height) |y| {
            c.write_pixel(x, y, color(1, 0.8, 0.6));
        }
    }
    var ppm = ArrayList(u8).init(testing.allocator);
    defer ppm.deinit();
    try c.to_ppm(ppm.writer());

    try expectEqualStrings(
        \\255 204 153 255 204 153 255 204 153 255 204 153 255 204 153 255 204
        \\153 255 204 153 255 204 153 255 204 153 255 204 153
        \\255 204 153 255 204 153 255 204 153 255 204 153 255 204 153 255 204
        \\153 255 204 153 255 204 153 255 204 153 255 204 153
    , stringLines(ppm.items, 4, 7));
}

test "PPM files are terminated by a newline character" {
    const c = try canvas(5, 3, &testing.allocator);
    defer c.deinit();
    var ppm = ArrayList(u8).init(testing.allocator);
    defer ppm.deinit();
    try c.to_ppm(ppm.writer());

    try expectEqual('\n', ppm.items[ppm.items.len - 1]);
}
