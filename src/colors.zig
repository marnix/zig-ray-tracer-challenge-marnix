const types = @import("types.zig");
const Float = types.Float;

const Color = struct {
    red: Float,
    green: Float,
    blue: Float,
};

fn color(r: Float, g: Float, b: Float) Color {
    return .{ .red = r, .green = g, .blue = b };
}

// // // // // // // // // // // // //
// The following is only for testing

const testing = @import("testing.zig");
const expect = testing.expect;
const expectEqF = testing.expectEqF;

test "Colors are (red, green, blue) tuples" {
    const c = color(-0.5, 0.4, 1.7);
    try expectEqF(-0.5, c.red);
    try expectEqF(0.4, c.green);
    try expectEqF(1.7, c.blue);
}
