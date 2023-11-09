const std = @import("std");

/// This is the basic floating-point type that we will use everywhere.
pub const Float = f32;

/// This is intended to be used as an immutable type.
const Tuple = struct {
    v: @Vector(4, Float),

    pub fn x(self: Tuple) Float {
        return self.v[0];
    }
    pub fn y(self: Tuple) Float {
        return self.v[1];
    }
    pub fn z(self: Tuple) Float {
        return self.v[2];
    }
    pub fn w(self: Tuple) Float {
        return self.v[3];
    }

    pub fn isPoint(self: Tuple) bool {
        return self.w() == 1.0;
    }
    pub fn isVector(self: Tuple) bool {
        return self.w() == 0.0;
    }
};

pub fn tuple(x: Float, y: Float, z: Float, w: Float) Tuple {
    return .{ .v = .{ x, y, z, w } };
}

// // // // // // // // // // // // //
// The following is only for testing

const expect = std.testing.expect;

// Later: Move this to a central test support .zig file
fn expectEqF(expected: anytype, actual: anytype) !void {
    try std.testing.expectApproxEqAbs(@as(f64, expected), @as(f64, actual), 1e-6);
}

test "A tuple with w=1.0 is a point" {
    const a = tuple(4.3, -4.2, 3.1, 1.0);
    try expectEqF(4.3, a.x());
    try expectEqF(-4.2, a.y());
    try expectEqF(3.1, a.z());
    try expectEqF(1.0, a.w());
    try expect(a.isPoint());
    try expect(!a.isVector());
}

test "A tuple with w=0.0 is a vector" {
    const a = tuple(4.3, -4.2, 3.1, 0.0);
    try expectEqF(4.3, a.x());
    try expectEqF(-4.2, a.y());
    try expectEqF(3.1, a.z());
    try expectEqF(0.0, a.w());
    try expect(!a.isPoint());
    try expect(a.isVector());
}
