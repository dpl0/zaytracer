///! This contains the canvas used for our raytracer.
///!
const std = @import("std");
const math = @import("math.zig");

const C = math.C;

pub const Canvas = struct {
    const Self = @This();

    height: usize,
    width: usize,
    pixels: []C,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, width: usize, height: usize) !Self {
        const size = height * width;

        const pixels = try allocator.alloc(C, size);
        @memset(pixels, C.init(0, 0, 0));

        return .{ .height = height, .width = width, .pixels = pixels, .allocator = allocator };
    }

    pub fn deinit(self: Self) void {
        self.allocator.free(self.pixels);
    }

    pub fn write(self: Self, x: usize, y: usize, pixel: C) void {
        const pos = y * self.width + x;
        self.pixels[pos] = pixel;
    }

    pub fn at(self: Self, x: usize, y: usize) C {
        const pos = y * self.width + x;
        return self.pixels[pos];
    }

    pub fn format(self: Self, writer: anytype) !void {
        // Header:
        // In here, 255 is the maximum color value.
        // Colors will be scaled from 0 to 255, this is used in C.toBytes.
        try writer.print("P3\n{} {}\n255\n", .{ self.width, self.height });

        for (0..self.height) |y| {
            var line_len: usize = 0;

            for (0..self.width) |x| {
                const pixel = self.at(x, y);
                const rgb = pixel.toBytes();

                for (rgb) |component| {
                    const component_len = std.fmt.count("{d}", .{component});

                    // Check if adding component (plus space if not at line start) exceeds 70 chars
                    const space_needed: usize = if (line_len == 0) 0 else 1;
                    if (line_len + space_needed + component_len > 70) {
                        try writer.writeByte('\n');
                        line_len = 0;
                    }

                    // Write separating space if not at start of line
                    if (line_len > 0) {
                        try writer.writeByte(' ');
                        line_len += 1;
                    }

                    try writer.print("{d}", .{component});
                    line_len += component_len;
                }
            }

            // Force a newline at the end of every image row
            if (y != self.height) {
                try writer.writeByte('\n');
            }
        }
    }

    /// Formats out the `Canvas` to the ppm file format..
    pub fn toPpm(self: Self, allocator: std.mem.Allocator) ![]u8 {
        return try allocator.print("{f}", .{self});
    }
};

// Tests

// Scenario: Creating a canvas
//   Given c ← canvas(10, 20)
//   Then c.width = 10
//     And c.height = 20
//     And every pixel of c is color(0, 0, 0)
test "creating a canvas" {
    const canvas = try Canvas.init(std.testing.allocator, 10, 20);
    defer canvas.deinit();

    for (canvas.pixels) |pixel| {
        try C.expectApproxEq(C.init(0, 0, 0), pixel);
    }
}

// Scenario: Writing pixels to a canvas
//   Given c ← canvas(10, 20)
//     And red ← color(1, 0, 0)
//   When write_pixel(c, 2, 3, red)
//   Then pixel_at(c, 2, 3) = red
test "writing pixels to a canvas" {
    var canvas = try Canvas.init(std.testing.allocator, 10, 20);
    defer canvas.deinit();
    const red = C.init(1, 0, 0);

    canvas.write(2, 3, red);
    try C.expectApproxEq(C.init(1, 0, 0), canvas.at(2, 3));
}

// Scenario: Constructing the PPM header
//   Given c ← canvas(5, 3)
//   When ppm ← canvas_to_ppm(c)
//   Then lines 1-3 of ppm are
//     """
//     P3
//     5 3
//     255
//     """
test "constructing the PPM header" {
    var canvas = try Canvas.init(std.testing.allocator, 5, 3);
    defer canvas.deinit();

    const ppm: []u8 = try canvas.to_ppm(std.testing.allocator);
    defer std.testing.allocator.free(ppm);

    const expected =
        \\P3
        \\5 3
        \\255
        \\
    ;

    try std.testing.expectEqualStrings(expected, ppm[0..expected.len]);
}

// Scenario: Constructing the PPM pixel data
//   Given c ← canvas(5, 3)
//     And c1 ← color(1.5, 0, 0)
//     And c2 ← color(0, 0.5, 0)
//     And c3 ← color(-0.5, 0, 1)
//   When write_pixel(c, 0, 0, c1)
//     And write_pixel(c, 2, 1, c2)
//     And write_pixel(c, 4, 2, c3)
//     And ppm ← canvas_to_ppm(c)
//   Then lines 4-6 of ppm are
//     """
//     255 0 0 0 0 0 0 0 0 0 0 0 0 0 0
//     0 0 0 0 0 0 0 128 0 0 0 0 0 0 0
//     0 0 0 0 0 0 0 0 0 0 0 0 0 0 255
//     """
test "constructing the PPM pixel data" {
    var canvas = try Canvas.init(std.testing.allocator, 5, 3);
    defer canvas.deinit();

    const c1 = C.init(1.5, 0, 0);
    const c2 = C.init(0, 0.5, 0);
    const c3 = C.init(-0.5, 0, 1);

    canvas.write(0, 0, c1);
    canvas.write(2, 1, c2);
    canvas.write(4, 2, c3);

    const ppm: []u8 = try canvas.to_ppm(std.testing.allocator);
    defer std.testing.allocator.free(ppm);

    const header =
        \\P3
        \\5 3
        \\255
        \\
    ;
    const expected =
        \\255 0 0 0 0 0 0 0 0 0 0 0 0 0 0
        \\0 0 0 0 0 0 0 128 0 0 0 0 0 0 0
        \\0 0 0 0 0 0 0 0 0 0 0 0 0 0 255
        \\
    ;

    try std.testing.expectEqualStrings(expected, ppm[header.len..]);
}

// Scenario: Splitting long lines in PPM files
//   Given c ← canvas(10, 2)
//   When every pixel of c is set to color(1, 0.8, 0.6)
//     And ppm ← canvas_to_ppm(c)
//   Then lines 4-7 of ppm are
//     """
//     255 204 153 255 204 153 255 204 153 255 204 153 255 204 153 255 204
//     153 255 204 153 255 204 153 255 204 153 255 204 153
//     255 204 153 255 204 153 255 204 153 255 204 153 255 204 153 255 204
//     153 255 204 153 255 204 153 255 204 153 255 204 153
//     """
test "splitting long lines in PPM files" {
    // This test is to make sure that we stick to 70 chars per line.
    var canvas = try Canvas.init(std.testing.allocator, 10, 2);
    defer canvas.deinit();

    const c = C.init(1, 0.8, 0.6);

    // Write out all pixels.
    @memset(canvas.pixels, c);

    const ppm: []u8 = try canvas.to_ppm(std.testing.allocator);
    defer std.testing.allocator.free(ppm);

    const header =
        \\P3
        \\10 2
        \\255
        \\
    ;
    const expected =
        \\255 204 153 255 204 153 255 204 153 255 204 153 255 204 153 255 204
        \\153 255 204 153 255 204 153 255 204 153 255 204 153
        \\255 204 153 255 204 153 255 204 153 255 204 153 255 204 153 255 204
        \\153 255 204 153 255 204 153 255 204 153 255 204 153
        \\
    ;

    try std.testing.expectEqualStrings(expected, ppm[header.len..]);
}

// Scenario: PPM files are terminated by a newline character
//   Given c ← canvas(5, 3)
//   When ppm ← canvas_to_ppm(c)
//   Then ppm ends with a newline character
test "PPM files are terminated by a newline character" {
    var canvas = try Canvas.init(std.testing.allocator, 5, 3);
    defer canvas.deinit();

    const ppm: []u8 = try canvas.to_ppm(std.testing.allocator);
    defer std.testing.allocator.free(ppm);

    try std.testing.expectEqual('\n', ppm[ppm.len - 1]);
}
