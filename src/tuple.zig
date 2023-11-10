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

    pub fn equals(self: Tuple, they: Tuple) bool {
        return self.x() == they.x() and self.y() == they.y() and self.z() == they.z() and self.w() == they.w();
    }

    pub fn isPoint(self: Tuple) bool {
        return self.w() == 1.0;
    }
    pub fn isVector(self: Tuple) bool {
        return self.w() == 0.0;
    }

    pub fn plus(self: Tuple, they: Tuple) Tuple {
        return .{ .v = .{ self.x() + they.x(), self.y() + they.y(), self.z() + they.z(), self.w() + they.w() } };
    }
    pub fn minus(self: Tuple, they: Tuple) Tuple {
        return .{ .v = .{ self.x() - they.x(), self.y() - they.y(), self.z() - they.z(), self.w() - they.w() } };
    }
    pub fn negate(self: Tuple) Tuple {
        return .{ .v = .{ -self.x(), -self.y(), -self.z(), -self.w() } };
    }
};

pub fn tuple(x: Float, y: Float, z: Float, w: Float) Tuple {
    return .{ .v = .{ x, y, z, w } };
}

pub fn point(x: Float, y: Float, z: Float) Tuple {
    return tuple(x, y, z, 1);
}

pub fn vector(x: Float, y: Float, z: Float) Tuple {
    return tuple(x, y, z, 0);
}

pub fn minus(self: Tuple) Tuple {
    return self.negate();
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

test "point() creates tuples with w=1" {
    const p = point(4, -4, 3);
    try expect(p.equals(tuple(4, -4, 3, 1)));
}

test "vector() creates tuples with w=0" {
    const p = vector(4, -4, 3);
    try expect(p.equals(tuple(4, -4, 3, 0)));
}

test "Adding two tuples" {
    const a1 = tuple(3, -2, 5, 1);
    const a2 = tuple(-2, 3, 1, 0);
    try expect(a1.plus(a2).equals(tuple(1, 1, 6, 1)));
}

test "Subtracting a vector from a point" {
    const p = point(3, 2, 1);
    const v = vector(5, 6, 7);
    try expect(p.minus(v).equals(point(-2, -4, -6)));
}

test "Subtracting two vectors" {
    const v1 = vector(3, 2, 1);
    const v2 = vector(5, 6, 7);
    try expect(v1.minus(v2).equals(vector(-2, -4, -6)));
}

test "Subtracting a vector from the zero vector" {
    const zero = vector(0, 0, 0);
    const v = vector(1, -2, 3);
    try expect(zero.minus(v).equals(vector(-1, 2, -3)));
}

test "Negating a tuple" {
    const a = tuple(1, -2, 3, -4);
    try expect(minus(a).equals(tuple(-1, 2, -3, 4)));
}
