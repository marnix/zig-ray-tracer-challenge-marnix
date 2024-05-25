const std = @import("std");
pub const std_options = std.Options{
    // 'info' is the default log level
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

    pub fn tick(self: Environment, proj: Projectile) Projectile {
        return Projectile.of(.{
            .position = proj.position.plus(proj.velocity),
            .velocity = proj.velocity.plus(self.gravity).plus(self.wind),
        });
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const c = try canvas(900, 550, &allocator);
    defer c.deinit();

    const projectileColor = color(255.0 / 255.0, 165.0 / 255.0, 0.0 / 255.0); // #FFA500 = orange

    var p = Projectile.of(.{ .position = point(0, 1, 0), .velocity = normalize(vector(1, 1.8, 0)).times(11.25) });
    const e = Environment.of(.{ .gravity = vector(0, -0.1, 0), .wind = vector(-0.01, 0, 0) });
    var t: usize = 0;
    while (p.position.y() > 0) {
        std.log.debug("distance is {}, height is {}", .{ p.position.x(), p.position.y() });
        c.write_pixel(@intFromFloat(p.position.x()), 550 - @as(usize, @intFromFloat(p.position.y())) - 1, projectileColor);
        p = e.tick(p);
        t = t + 1;
    }

    std.log.info("ready to write.", .{});

    const ppmFile = try std.fs.cwd().createFile("chapter-02-cannon.ppm", .{});
    try c.to_ppm(ppmFile.writer());
}
