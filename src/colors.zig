const types = @import("types.zig");
pub const Float = types.Float;

pub const Color = struct {
    red: Float,
    green: Float,
    blue: Float,

    pub fn plus(self: Color, they: Color) Color {
        return .{
            .red = self.red + they.red,
            .green = self.green + they.green,
            .blue = self.blue + they.blue,
        };
    }

    pub fn minus(self: Color, they: Color) Color {
        return .{
            .red = self.red - they.red,
            .green = self.green - they.green,
            .blue = self.blue - they.blue,
        };
    }

    pub fn timesF(self: Color, f: Float) Color {
        return .{
            .red = f * self.red,
            .green = f * self.green,
            .blue = f * self.blue,
        };
    }

    /// The Hadamard product or Schur product.
    pub fn times(self: Color, they: Color) Color {
        return .{
            .red = self.red * they.red,
            .green = self.green * they.green,
            .blue = self.blue * they.blue,
        };
    }

    /// Convert the given floating point number 0..1 to an integer in the range 0..max (inclusive!),
    /// 'cropping' to that interval if necessary.
    /// Linear (so just multiplies by 'max'), rounds towards nearest integer, .5 rounds up.
    pub fn asInt(comptime T: type, max: T, f: Float) T {
        if (f < 0) return 0;
        if (f > 1) return max;
        return @intFromFloat(@round(f * @as(Float, @floatFromInt(max))));
    }
};

pub fn color(r: Float, g: Float, b: Float) Color {
    return .{ .red = r, .green = g, .blue = b };
}

// // // // // // // // // // // // //
// The following is only for testing

const testing = @import("testing.zig");
const expect = testing.expect;
const expectEqF = testing.expectEqF;

fn expectEqC(expected: Color, actual: Color) !void {
    try expectEqF(expected.red, actual.red);
    try expectEqF(expected.green, actual.green);
    try expectEqF(expected.blue, actual.blue);
}

test "Colors are (red, green, blue) tuples" {
    const c = color(-0.5, 0.4, 1.7);
    try expectEqF(-0.5, c.red);
    try expectEqF(0.4, c.green);
    try expectEqF(1.7, c.blue);
}

test "Adding colors" {
    const c1 = color(0.9, 0.6, 0.75);
    const c2 = color(0.7, 0.1, 0.25);
    try expectEqC(color(1.6, 0.7, 1.0), c1.plus(c2));
}

test "Subtracting colors" {
    const c1 = color(0.9, 0.6, 0.75);
    const c2 = color(0.7, 0.1, 0.25);
    try expectEqC(color(0.2, 0.5, 0.5), c1.minus(c2));
}

test "Multiplying a color by a scalar" {
    const c = color(0.2, 0.3, 0.4);
    try expectEqC(color(0.4, 0.6, 0.8), c.timesF(2));
}

test "Multiplying colors" {
    const c1 = color(1, 0.2, 0.4);
    const c2 = color(0.9, 1, 0.1);
    try expectEqC(color(0.9, 0.2, 0.04), c1.times(c2));
}
