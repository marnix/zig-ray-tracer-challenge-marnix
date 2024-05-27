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
                    result.data[rowNr * nrColumns + columnNr] = v;
                }
            }
            return result;
        }

        /// Get a specific value, indices are zero-based.
        pub fn at(self: Self, rowNr: usize, columnNr: usize) Float {
            return self.data[rowNr * nrColumns + columnNr];
        }
    };
}

// // // // // // // // // // // // //
// The following is only for testing

const testing = @import("testing.zig");
const expect = testing.expect;
const expectEqF = testing.expectEqF;

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
