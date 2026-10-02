const std = @import("std");
const builtin = @import("builtin");

const zaytracer = @import("zaytracer");
const Canvas = zaytracer.canvas.Canvas;
const C = zaytracer.math.C;

pub fn saveCanvasToFile(path: []const u8, canvas: Canvas, io: std.Io) !void {
    const cwd: std.Io.Dir = std.Io.Dir.cwd();
    var file: std.Io.File = try cwd.createFile(io, path, .{});
    defer file.close(io);

    var buf: [4096]u8 = undefined;
    var writer = file.writer(io, &buf);
    try canvas.format(&writer.interface);
    try writer.flush();
}

fn lerp(a: f32, b: f32, t: f32) f32 {
    return a + (b - a) * t;
}

fn mix(a: C, b: C, t: f32) C {
    return C.init(lerp(a.r, b.r, t), lerp(a.g, b.g, t), lerp(a.b, b.b, t));
}

fn smoothstep(t: f32) f32 {
    return t * t * (3 - 2 * t);
}

pub fn fillGradient(canvas: Canvas, tl: C, tr: C, bl: C, br: C) void {
    const w: f32 = @floatFromInt(@max(canvas.width - 1, 1));
    const h: f32 = @floatFromInt(@max(canvas.height - 1, 1));

    for (0..canvas.height) |y| {
        const v = smoothstep(@as(f32, @floatFromInt(y)) / h);
        for (0..canvas.width) |x| {
            const u = smoothstep(@as(f32, @floatFromInt(x)) / w);
            const top = mix(tl, tr, u);
            const bottom = mix(bl, br, u);
            canvas.write(x, y, mix(top, bottom, v));
        }
    }
}

pub fn main(init: std.process.Init) !void {
    var safe_allocator: std.heap.SafeAllocator = .init(std.heap.smp_allocator, .{});
    defer {
        const leaks = safe_allocator.deinit();
        if (leaks != 0) std.debug.print("leaked {} allocations\n", .{leaks});
    }

    const allocator: std.mem.Allocator = switch (builtin.mode) {
        .debug, .safe => safe_allocator.allocator(),
        .fast, .small => std.heap.smp_allocator,
    };

    var canvas = try Canvas.init(allocator, 1920, 1080);
    defer canvas.deinit();
    fillGradient(
        canvas,
        C.init(0.10, 0.05, 0.35), // top-left: deep indigo
        C.init(0.30, 0.10, 0.45), // top-right: violet
        C.init(1.00, 0.65, 0.20), // bottom-left: warm orange
        C.init(0.85, 0.20, 0.50), // bottom-right: magenta
    );

    // const file_path = std.Io.Dir.path("output.ppm");
    try saveCanvasToFile("output.ppm", canvas, init.io);
}
