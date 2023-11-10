const std = @import("std");
const tuples = @import("tuples.zig");
const point = tuples.point;
const vector = tuples.vector;
const normalize = tuples.normalize;

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

pub fn main() void {
    var p = Projectile.of(.{ .position = point(0, 1, 0), .velocity = normalize(vector(1, 1, 0)) });
    const e = Environment.of(.{ .gravity = vector(0, -0.1, 0), .wind = vector(-0.01, 0, 0) });
    var t: usize = 0;
    while (p.position.y() > 0) {
        std.log.info("distance is {}, height is {}", .{ p.position.x(), p.position.y() });
        p = tick(e, p);
        t = t + 1;
    }
    std.log.info("After {} ticks, the final distance is {}, height is {}", .{ t, p.position.x(), p.position.y() });
}
