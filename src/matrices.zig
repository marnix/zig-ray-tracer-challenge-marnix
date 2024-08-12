const std = @import("std");

const types = @import("types.zig");
const Float = types.Float;

fn Matrix(comptime nrRows: usize, comptime nrColumns: usize) type {
    return struct {
        const Self = @This();

        data: @Vector(nrRows * nrColumns, Float) = undefined,

        pub fn of(matrix_values: [nrRows][nrColumns]Float) Self {
            var result = Self{};
            for (matrix_values, 0..) |row, rowNr| {
                for (row, 0..) |v, columnNr| {
                    result.set(rowNr, columnNr, v);
                }
            }
            return result;
        }

        /// Get a specific value, indices are zero-based.
        pub fn at(self: Self, rowNr: usize, columnNr: usize) Float {
            return self.data[rowNr * nrColumns + columnNr];
        }

        /// Set a specific value, indices are zero-based.
        pub fn set(self: *Self, rowNr: usize, columnNr: usize, value: Float) void {
            self.data[rowNr * nrColumns + columnNr] = value;
        }

        /// Limitation: Currently only allows multiplying square matrices...
        pub fn times(self: Self, they: Self) Self {
            // Later: See if the implementation can be sped up using @Vector inner products?
            var result = Self{};
            for (0..nrColumns) |columnNr| {
                for (0..nrRows) |rowNr| {
                    var sum: Float = 0;
                    for (0..nrColumns) |i| {
                        sum += self.at(rowNr, i) * they.at(i, columnNr);
                    }
                    result.set(rowNr, columnNr, sum);
                }
            }
            return result;
        }
    };
}

// // // // // // // // // // // // //
// The following is only for testing

const testing = @import("testing.zig");
const expect = testing.expect;
const expectEqF = testing.expectEqF;
const expectEqual = testing.expectEqual_;

fn vectorLen(v: anytype) usize {
    return @typeInfo(@TypeOf(v)).Vector.len; // just v.len might work in the future...
}

fn expectEqM(expected: anytype, actual: anytype) !void {
    for (0..vectorLen(expected.data)) |i| {
        try expectEqF(expected.data[i], actual.data[i]);
    }
}

test "Constructing and inspecting a 4x4 matrix" {
    const matrix = Matrix(4, 4).of([4][4]Float{
        [_]Float{ 1, 2, 3, 4 },
        [_]Float{ 5.5, 6.5, 7.5, 8.5 },
        [_]Float{ 9, 10, 11, 12 },
        [_]Float{ 13.5, 14.5, 15.5, 16.5 },
    });
    try expectEqF(4, matrix.at(0, 3));
    try expectEqF(5.5, matrix.at(1, 0));
    try expectEqF(7.5, matrix.at(1, 2));
    try expectEqF(11, matrix.at(2, 2));
    try expectEqF(13.5, matrix.at(3, 0));
    try expectEqF(15.5, matrix.at(3, 2));
}

test "A 2x2 matrix ought to be representable" {
    const matrix = Matrix(2, 2).of([2][2]Float{
        [_]Float{ -3, 5 },
        [_]Float{ 1, -2 },
    });
    try expectEqF(-3, matrix.at(0, 0));
    try expectEqF(5, matrix.at(0, 1));
    try expectEqF(1, matrix.at(1, 0));
    try expectEqF(-2, matrix.at(1, 1));
}

test "A 3x3 matrix ought to be representable" {
    const matrix = Matrix(3, 3).of([3][3]Float{
        [_]Float{ -3, 5, 0 },
        [_]Float{ 1, -2, -7 },
        [_]Float{ 0, 1, 1 },
    });
    try expectEqF(-3, matrix.at(0, 0));
    try expectEqF(-2, matrix.at(1, 1));
    try expectEqF(1, matrix.at(2, 2));
}

test "Matrix equality with identical matrices" {
    const a = Matrix(4, 4).of([4][4]Float{
        [_]Float{ 1, 2, 3, 4 },
        [_]Float{ 5, 6, 7, 8 },
        [_]Float{ 9, 8, 7, 6 },
        [_]Float{ 5, 4, 3, 2 },
    });
    const b = Matrix(4, 4).of([4][4]Float{
        [_]Float{ 1, 2, 3, 4 },
        [_]Float{ 5, 6, 7, 8 },
        [_]Float{ 9, 8, 7, 6 },
        [_]Float{ 5, 4, 3, 2 },
    });
    try expectEqM(a, b);
}

test "Matrix equality with different matrices" {
    const a = Matrix(4, 4).of([4][4]Float{
        [_]Float{ 1, 2, 3, 4 },
        [_]Float{ 5, 6, 7, 8 },
        [_]Float{ 9, 8, 7, 6 },
        [_]Float{ 5, 4, 3, 2 },
    });
    const b = Matrix(4, 4).of([4][4]Float{
        [_]Float{ 2, 3, 4, 5 },
        [_]Float{ 6, 7, 8, 9 },
        [_]Float{ 8, 7, 6, 5 },
        [_]Float{ 4, 3, 2, 1 },
    });
    try expectEqual(error.TestExpectedApproxEqAbs, expectEqM(a, b));
}

test "Multiplying two matrices" {
    const a = Matrix(4, 4).of([4][4]Float{
        [_]Float{ 1, 2, 3, 4 },
        [_]Float{ 5, 6, 7, 8 },
        [_]Float{ 9, 8, 7, 6 },
        [_]Float{ 5, 4, 3, 2 },
    });
    const b = Matrix(4, 4).of([4][4]Float{
        [_]Float{ -2, 1, 2, 3 },
        [_]Float{ 3, 2, 1, -1 },
        [_]Float{ 4, 3, 6, 5 },
        [_]Float{ 1, 2, 7, 8 },
    });
    try expectEqM(Matrix(4, 4).of([4][4]Float{
        [_]Float{ 20, 22, 50, 48 },
        [_]Float{ 44, 54, 114, 108 },
        [_]Float{ 40, 58, 110, 102 },
        [_]Float{ 16, 26, 46, 42 },
    }), a.times(b));
}
