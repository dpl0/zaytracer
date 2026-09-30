//! Root library file for zaytracer, a simple raytracer following the Ray Tracer Challenge, in Zig.

const std = @import("std");
const Io = std.Io;

pub const math = @import("math.zig");

test {
    _ = math;
}
