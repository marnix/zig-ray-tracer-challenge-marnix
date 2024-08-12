const std = @import("std");

const types = @import("types.zig");
const Float = types.Float;
const sqrt = types.sqrt;

/// This is intended to be used as an immutable type.
pub const Tuple = struct {
    v: @Vector(4, Float),

    pub fn at(self: Tuple, rowNr: usize) Float {
        return self.v[rowNr];
    }

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
        return self.v == they.v;
    }

    pub fn isPoint(self: Tuple) bool {
        return self.w() == 1.0;
    }
    pub fn isVector(self: Tuple) bool {
        return self.w() == 0.0;
    }

    pub fn plus(self: Tuple, they: Tuple) Tuple {
        return .{ .v = self.v + they.v };
    }
    pub fn minus(self: Tuple, they: Tuple) Tuple {
        return .{ .v = self.v - they.v };
    }
    pub fn negate(self: Tuple) Tuple {
        return self.times(-1);
    }
    pub fn times(self: Tuple, f: Float) Tuple {
        return .{ .v = self.v * @as(@TypeOf(self.v), @splat(f)) };
    }
    pub fn div(self: Tuple, f: Float) Tuple {
        return self.times(1 / f);
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

pub fn normalize(self: Tuple) Tuple {
    return self.div(magnitude(self));
}

pub fn magnitude(self: Tuple) Float {
    std.debug.assert(self.isVector());
    return sqrt(dot(self, self));
}

pub fn dot(self: Tuple, they: Tuple) Float {
    return @reduce(.Add, self.v * they.v);
}

pub fn cross(self: Tuple, they: Tuple) Tuple {
    return vector(
        self.y() * they.z() - self.z() * they.y(),
        self.z() * they.x() - self.x() * they.z(),
        self.x() * they.y() - self.y() * they.x(),
    );
}

// // // // // // // // // // // // //
// The following is only for testing

const testing = @import("testing.zig");
const expect = testing.expect;
const expectEqF = testing.expectEqF;

pub fn expectEqT(expected: Tuple, actual: Tuple) !void {
    try expectEqF(expected.x(), actual.x());
    try expectEqF(expected.y(), actual.y());
    try expectEqF(expected.z(), actual.z());
    try expectEqF(expected.w(), actual.w());
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
    try expectEqT(tuple(4, -4, 3, 1), p);
}

test "vector() creates tuples with w=0" {
    const p = vector(4, -4, 3);
    try expectEqT(tuple(4, -4, 3, 0), p);
}

test "Adding two tuples" {
    const a1 = tuple(3, -2, 5, 1);
    const a2 = tuple(-2, 3, 1, 0);
    try expectEqT(tuple(1, 1, 6, 1), a1.plus(a2));
}

test "Subtracting a vector from a point" {
    const p = point(3, 2, 1);
    const v = vector(5, 6, 7);
    try expectEqT(point(-2, -4, -6), p.minus(v));
}

test "Subtracting two vectors" {
    const v1 = vector(3, 2, 1);
    const v2 = vector(5, 6, 7);
    try expectEqT(vector(-2, -4, -6), v1.minus(v2));
}

test "Subtracting a vector from the zero vector" {
    const zero = vector(0, 0, 0);
    const v = vector(1, -2, 3);
    try expectEqT(vector(-1, 2, -3), zero.minus(v));
}

test "Negating a tuple" {
    const a = tuple(1, -2, 3, -4);
    try expectEqT(tuple(-1, 2, -3, 4), minus(a));
}

test "Multiplying a tuple by a scalar" {
    const a = tuple(1, -2, 3, -4);
    try expectEqT(tuple(3.5, -7, 10.5, -14), a.times(3.5));
}

test "Multiplying a tuple by a fraction" {
    const a = tuple(1, -2, 3, -4);
    try expectEqT(tuple(0.5, -1, 1.5, -2), a.times(0.5));
}

test "Dividing a tuple by a scalar" {
    const a = tuple(1, -2, 3, -4);
    try expectEqT(tuple(0.5, -1, 1.5, -2), a.div(2));
}

test "Computing the magnitude of vector(1, 0, 0)" {
    const v = vector(1, 0, 0);
    try expectEqF(1, magnitude(v));
}

test "Computing the magnitude of vector(0, 1, 0)" {
    const v = vector(0, 1, 0);
    try expectEqF(1, magnitude(v));
}

test "Computing the magnitude of vector(0, 0, 1)" {
    const v = vector(0, 0, 1);
    try expectEqF(1, magnitude(v));
}

test "Computing the magnitude of vector(1, 2, 3)" {
    const v = vector(1, 2, 3);
    try expectEqF(sqrt(14), magnitude(v));
}

test "Computing the magnitude of vector(-1, -2, -3)" {
    const v = vector(1, 2, 3);
    try expectEqF(sqrt(14), magnitude(v));
}

test "Normalizing vector(4, 0, 0) gives (1, 0, 0)" {
    const v = vector(4, 0, 0);
    try expectEqT(vector(1, 0, 0), normalize(v));
}

test "Normalizing vector(1, 2, 3)" {
    const v = vector(1, 2, 3);
    const norm = normalize(v);
    try expectEqF(1, magnitude(norm));
}

test "The dot product of two tuples" {
    const a = vector(1, 2, 3);
    const b = vector(2, 3, 4);
    try expectEqF(20, dot(a, b));
}

test "The cross product of two tuples" {
    const a = vector(1, 2, 3);
    const b = vector(2, 3, 4);
    try expectEqT(vector(-1, 2, -1), cross(a, b));
    try expectEqT(vector(1, -2, 1), cross(b, a));
}
