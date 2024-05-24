const std = @import("std");
pub const std_options = std.Options{
    .log_level = .info,
};

const tuples = @import("tuples.zig");
const point = tuples.point;
const vector = tuples.vector;
const normalize = tuples.normalize;
const canvases = @import("canvases.zig");
const canvas = canvases.canvas;
const colors = @import("colors.zig");
const color = colors.color;

/// A Tuple that is actually a point.
const Point = tuples.Tuple;

/// A Tuple that is actually a vector.
const Vector = tuples.Tuple;

const Projectile = struct {
    position: Point,
    velocity: Vector,

    fn of(self: Projectile) Projectile {
        std.debug.assert(self.position.isPoint());
        std.debug.assert(self.velocity.isVector());
        return self;
    }
};

const Environment = struct {
    gravity: Vector,
    wind: Vector,

    fn of(self: Environment) Environment {
        std.debug.assert(self.gravity.isVector());
        std.debug.assert(self.wind.isVector());
        return self;
    }
};

pub fn tick(env: Environment, proj: Projectile) Projectile {
    return Projectile.of(.{
        .position = proj.position.plus(proj.velocity),
        .velocity = proj.velocity.plus(env.gravity).plus(env.wind),
    });
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const c = try canvas(900, 550, &allocator);
    defer c.deinit();

    const white = color(1, 1, 1);
    c.write_pixel(450, 225, white);

    std.log.info("ready to write.", .{});

    const ppmFile = try std.fs.cwd().createFile("test.ppm", .{});
    try c.to_ppm(ppmFile.writer());
}
