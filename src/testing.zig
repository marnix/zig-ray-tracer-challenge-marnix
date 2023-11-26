/// This module extends std.testing with custom test support code.
const std = @import("std");
pub usingnamespace std.testing;

// Later: Move this to a central test support .zig file
pub fn expectEqF(expected: anytype, actual: anytype) !void {
    try std.testing.expectApproxEqAbs(@as(f64, expected), @as(f64, actual), 1e-6);
}

/// This function is intended to be used only in tests. When the two values are not
/// equal, prints diagnostics to stderr to show exactly how they are not equal,
/// then returns a test failure error.
/// `expected` is casted to the type of `actual`.
pub fn expectEqual_(expected: anytype, actual: anytype) !void {
    try std.testing.expectEqual(@as(@TypeOf(actual), expected), actual);
}
