/// This module extends std.testing with custom test support code.
const std = @import("std");
pub usingnamespace std.testing;

// Later: Move this to a central test support .zig file
pub fn expectEqF(expected: anytype, actual: anytype) !void {
    try std.testing.expectApproxEqAbs(@as(f64, expected), @as(f64, actual), 1e-6);
}
