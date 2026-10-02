//! Root library file for zaytracer, a simple raytracer following the Ray Tracer Challenge, in Zig.

const std = @import("std");

pub const math = @import("math.zig");
pub const canvas = @import("canvas.zig");

test {
    _ = math;
    _ = canvas;
}
