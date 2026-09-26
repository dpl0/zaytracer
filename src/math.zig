///! All math related stuff for the raytracer. It's going to be a lot.
///!
///! # Vectorial structures
///! This includes vector and point types. These are the operation tables regarding types:
///!
///!
const std = @import("std");

/// Minimum value for differentiating two f32 values.
const epsilon: f32 = 1e-5;

/// Point type
pub const P = struct {
    const Self = @This();
    x: f32,
    y: f32,
    z: f32,

    /// Useful for testing similarity with other vectors.
    pub fn expectApproxEq(expected: Self, actual: Self) !void {
        try std.testing.expectApproxEqAbs(expected.x, actual.x, epsilon);
        try std.testing.expectApproxEqAbs(expected.y, actual.y, epsilon);
        try std.testing.expectApproxEqAbs(expected.z, actual.z, epsilon);
    }

    pub fn init(x: f32, y: f32, z: f32) Self {
        return .{ .x = x, .y = y, .z = z };
    }

    pub fn add(self: Self, other: V) Self {
        return .{
            .x = self.x + other.x,
            .y = self.y + other.y,
            .z = self.z + other.z,
        };
    }

    pub fn sub(self: Self, other: Self) V {
        return .{
            .x = self.x - other.x,
            .y = self.y - other.y,
            .z = self.z - other.z,
        };
    }

    pub fn subV(self: Self, other: V) Self {
        return .{
            .x = self.x - other.x,
            .y = self.y - other.y,
            .z = self.z - other.z,
        };
    }

    pub fn mul(self: Self, scalar: f32) Self {
        return .{
            .x = self.x * scalar,
            .y = self.y * scalar,
            .z = self.z * scalar,
        };
    }

    pub fn div(self: Self, scalar: f32) Self {
        return .{
            .x = self.x / scalar,
            .y = self.y / scalar,
            .z = self.z / scalar,
        };
    }
};

/// Vector type
pub const V = struct {
    const Self = @This();
    x: f32,
    y: f32,
    z: f32,

    /// Useful for testing similarity with other vectors.
    pub fn expectApproxEq(expected: Self, actual: Self) !void {
        try std.testing.expectApproxEqAbs(expected.x, actual.x, epsilon);
        try std.testing.expectApproxEqAbs(expected.y, actual.y, epsilon);
        try std.testing.expectApproxEqAbs(expected.z, actual.z, epsilon);
    }

    pub fn init(x: f32, y: f32, z: f32) Self {
        return .{ .x = x, .y = y, .z = z };
    }

    pub fn add(self: Self, other: Self) Self {
        return .{
            .x = self.x + other.x,
            .y = self.y + other.y,
            .z = self.z + other.z,
        };
    }

    pub fn addP(self: Self, other: P) P {
        return .{
            .x = self.x + other.x,
            .y = self.y + other.y,
            .z = self.z + other.z,
        };
    }

    pub fn sub(self: Self, other: Self) Self {
        return .{
            .x = self.x - other.x,
            .y = self.y - other.y,
            .z = self.z - other.z,
        };
    }

    pub fn mul(self: Self, scalar: f32) Self {
        return .{
            .x = self.x * scalar,
            .y = self.y * scalar,
            .z = self.z * scalar,
        };
    }

    pub fn div(self: Self, scalar: f32) Self {
        return .{
            .x = self.x / scalar,
            .y = self.y / scalar,
            .z = self.z / scalar,
        };
    }

    pub fn negate(self: Self) Self {
        return .{ .x = -self.x, .y = -self.y, .z = -self.z };
    }

    pub fn magnitude(self: Self) f32 {
        return @sqrt(self.x * self.x + self.y * self.y + self.z * self.z);
    }

    pub fn normalize(self: Self) Self {
        const m = self.magnitude();
        return .{
            .x = self.x / m,
            .y = self.y / m,
            .z = self.z / m,
        };
    }

    pub fn dot(self: Self, other: Self) f32 {
        return self.x * other.x +
            self.y * other.y +
            self.z * other.z;
    }

    pub fn cross(self: Self, other: Self) Self {
        return .{
            .x = self.y * other.z - self.z * other.y,
            .y = self.z * other.x - self.x * other.z,
            .z = self.x * other.y - self.y * other.x,
        };
    }
};

/// Color type
pub const C = struct {
    const Self = @This();
    r: f32,
    g: f32,
    b: f32,

    /// Useful for testing similarity with other vectors.
    pub fn expectApproxEq(expected: Self, actual: Self) !void {
        try std.testing.expectApproxEqAbs(expected.r, actual.r, epsilon);
        try std.testing.expectApproxEqAbs(expected.g, actual.g, epsilon);
        try std.testing.expectApproxEqAbs(expected.b, actual.b, epsilon);
    }

    pub fn init(x: f32, y: f32, z: f32) Self {
        return .{ .r = x, .g = y, .b = z };
    }

    pub fn add(self: Self, other: Self) Self {
        return .{
            .r = self.r + other.r,
            .g = self.g + other.g,
            .b = self.b + other.b,
        };
    }

    pub fn sub(self: Self, other: Self) Self {
        return .{
            .r = self.r - other.r,
            .g = self.g - other.g,
            .b = self.b - other.b,
        };
    }

    pub fn mul(self: Self, scalar: f32) Self {
        return .{
            .r = self.r * scalar,
            .g = self.g * scalar,
            .b = self.b * scalar,
        };
    }

    pub fn div(self: Self, scalar: f32) Self {
        return .{
            .r = self.r / scalar,
            .g = self.g / scalar,
            .b = self.b / scalar,
        };
    }

    pub fn mulC(self: Self, other: Self) Self {
        return .{
            .r = self.r * other.r,
            .g = self.g * other.g,
            .b = self.b * other.b,
        };
    }
};

// # Tests

// Scenario: Adding two tuples
//   Given a1 ← tuple(3, -2, 5, 1)
//     And a2 ← tuple(-2, 3, 1, 0)
//    Then a1 + a2 = tuple(1, 1, 6, 1)
test "adding two V" {
    const a1 = V.init(3, -2, 5);
    const a2 = V.init(-2, 3, 1);
    const result = a1.add(a2);
    try std.testing.expectEqual(result, V.init(1, 1, 6));
}

// Scenario: Subtracting two points
//   Given p1 ← point(3, 2, 1)
//     And p2 ← point(5, 6, 7)
//   Then p1 - p2 = vector(-2, -4, -6)
test "subtracting two points" {
    const p1 = P.init(3, 2, 1);
    const p2 = P.init(5, 6, 7);
    const result: V = p1.sub(p2);
    try std.testing.expectEqual(result, V.init(-2, -4, -6));
}

// Scenario: Subtracting a vector from a point
//   Given p ← point(3, 2, 1)
//     And v ← vector(5, 6, 7)
//   Then p - v = point(-2, -4, -6)
test "subtracting a vector from a point" {
    const p = P.init(3, 2, 1);
    const v = V.init(5, 6, 7);
    const result: P = p.subV(v);
    try std.testing.expectEqual(result, P.init(-2, -4, -6));
}

// Scenario: Subtracting two vectors
//   Given v1 ← vector(3, 2, 1)
//     And v2 ← vector(5, 6, 7)
//   Then v1 - v2 = vector(-2, -4, -6)
test "subtracting two vectors" {
    const v1 = V.init(3, 2, 1);
    const v2 = V.init(5, 6, 7);
    try std.testing.expectEqual(v1.sub(v2), V.init(-2, -4, -6));
}

// Scenario: Subtracting a vector from the zero vector
//   Given zero ← vector(0, 0, 0)
//     And v ← vector(1, -2, 3)
//   Then zero - v = vector(-1, 2, -3)
test "subtracting a vector from the zero vector" {
    const z = V.init(0, 0, 0);
    const v = V.init(1, -2, 3);
    try std.testing.expectEqual(z.sub(v), V.init(-1, 2, -3));
}

// Scenario: Negating a tuple
//   Given a ← tuple(1, -2, 3, -4)
//   Then -a = tuple(-1, 2, -3, 4)
test "negating a tuple" {
    const negated = V.init(1, -2, 3).negate();
    try std.testing.expectEqual(negated, V.init(-1, 2, -3));
}

// Scenario: Multiplying a tuple by a scalar
//   Given a ← tuple(1, -2, 3, -4)
//   Then a * 3.5 = tuple(3.5, -7, 10.5, -14)
test "multiplying a tuple by a scalar" {
    const v = V.init(1, -2, 3);
    try std.testing.expectEqual(v.mul(3.5), V.init(3.5, -7, 10.5));

    const p = P.init(1, -2, 3);
    try std.testing.expectEqual(p.mul(3.5), P.init(3.5, -7, 10.5));
}

// Scenario: Multiplying a tuple by a fraction
//   Given a ← tuple(1, -2, 3, -4)
//   Then a * 0.5 = tuple(0.5, -1, 1.5, -2)
test "multiplying a tuple by a fraction" {
    const v = V.init(1, -2, 3);
    try std.testing.expectEqual(v.mul(0.5), V.init(0.5, -1, 1.5));

    const p = P.init(1, -2, 3);
    try std.testing.expectEqual(p.mul(0.5), P.init(0.5, -1, 1.5));
}

// Scenario: Dividing a tuple by a scalar
//   Given a ← tuple(1, -2, 3, -4)
//   Then a / 2 = tuple(0.5, -1, 1.5, -2)
test "dividing a tuple by a scalar" {
    const v = V.init(1, -2, 3);
    try std.testing.expectEqual(v.div(2), V.init(0.5, -1, 1.5));

    const p = P.init(1, -2, 3);
    try std.testing.expectEqual(p.div(2), P.init(0.5, -1, 1.5));
}

// Scenario: Computing the magnitude of vector(1, 0, 0)
//   Given v ← vector(1, 0, 0)
//   Then magnitude(v) = 1
test "computing the magnitude of vector(1,0,0)" {
    const unit = V.init(1, 0, 0);
    try std.testing.expectEqual(unit.magnitude(), 1);
}

// Scenario: Computing the magnitude of vector(0, 1, 0)
//   Given v ← vector(0, 1, 0)
//   Then magnitude(v) = 1
test "computing the magnitude of vector(0,1,0)" {
    const unit = V.init(0, 1, 0);
    try std.testing.expectEqual(unit.magnitude(), 1);
}

// Scenario: Computing the magnitude of vector(0, 0, 1)
//   Given v ← vector(0, 0, 1)
//   Then magnitude(v) = 1
test "computing the magnitude of vector(0,0,1)" {
    const unit = V.init(0, 0, 1);
    try std.testing.expectEqual(unit.magnitude(), 1);
}

// Scenario: Computing the magnitude of vector(1, 2, 3)
//   Given v ← vector(1, 2, 3)
//   Then magnitude(v) = √14
test "computing the magnitude of vector(1,2,3)" {
    const vector = V.init(1, 2, 3);
    try std.testing.expectEqual(vector.magnitude(), @sqrt(14.0));
}

// Scenario: Computing the magnitude of vector(-1, -2, -3)
//   Given v ← vector(-1, -2, -3)
//   Then magnitude(v) = √14
test "computing the magnitude of vector(-1,-2,-3)" {
    const vector = V.init(-1, -2, -3);
    try std.testing.expectApproxEqAbs(vector.magnitude(), @sqrt(14.0), epsilon);
}

// Scenario: Normalizing vector(4, 0, 0) gives (1, 0, 0)
//   Given v ← vector(4, 0, 0)
//   Then normalize(v) = vector(1, 0, 0)
test "normalizing vector(4, 0, 0) gives (1, 0, 0)" {
    const vector = V.init(4, 0, 0);
    try std.testing.expectEqual(vector.normalize(), V.init(1, 0, 0));
}

// Scenario: Normalizing vector(1, 2, 3)
//   Given v ← vector(1, 2, 3)
//                                   # vector(1/√14,   2/√14,   3/√14)
//   Then normalize(v) = approximately vector(0.26726, 0.53452, 0.80178)
test "normalizing vector(1, 2, 3)" {
    const vector = V.init(1, 2, 3);
    const denominator = @sqrt(14.0);
    const result = V.init(1.0 / denominator, 2.0 / denominator, 3.0 / denominator);

    try V.expectApproxEq(vector.normalize(), result);
}

// Scenario: The magnitude of a normalized vector
//   Given v ← vector(1, 2, 3)
//   When norm ← normalize(v)
//   Then magnitude(norm) = 1

test "the magnitude of a normalized vector is 1" {
    const vector = V.init(1, 2, 3);
    try std.testing.expectApproxEqAbs(vector.normalize().magnitude(), 1.0, epsilon);
}

// Scenario: The dot product of two tuples
//   Given a ← vector(1, 2, 3)
//     And b ← vector(2, 3, 4)
//   Then dot(a, b) = 20
test "the dot product of two tuples" {
    const v1 = V.init(1, 2, 3);
    const v2 = V.init(2, 3, 4);
    try std.testing.expectEqual(v1.dot(v2), 20.0);
    try std.testing.expectEqual(v2.dot(v1), 20.0);
    try std.testing.expectEqual(V.dot(v1, v2), 20.0);
}

// Scenario: The cross product of two vectors
//   Given a ← vector(1, 2, 3)
//     And b ← vector(2, 3, 4)
//   Then cross(a, b) = vector(-1, 2, -1)
//     And cross(b, a) = vector(1, -2, 1)
test "the cross product of two tuples" {
    const a = V.init(1, 2, 3);
    const b = V.init(2, 3, 4);
    try std.testing.expectEqual(a.cross(b), V.init(-1, 2, -1));
    try std.testing.expectEqual(b.cross(a), V.init(1, -2, 1));
}

// Scenario: Colors are (red, green, blue) tuples
//   Given c ← color(-0.5, 0.4, 1.7)
//   Then c.red = -0.5
//     And c.green = 0.4
//     And c.blue = 1.7
test "colors are (r, g, b) tuples" {
    const c = C.init(-0.5, 0.4, 1.7);
    try std.testing.expectEqual(c.r, -0.5);
    try std.testing.expectEqual(c.g, 0.4);
    try std.testing.expectEqual(c.b, 1.7);
}

// Scenario: Adding colors
//   Given c1 ← color(0.9, 0.6, 0.75)
//     And c2 ← color(0.7, 0.1, 0.25)
//    Then c1 + c2 = color(1.6, 0.7, 1.0)
test "adding colors" {
    const a = C.init(0.9, 0.6, 0.75);
    const b = C.init(0.7, 0.1, 0.25);

    try C.expectApproxEq(a.add(b), C.init(1.6, 0.7, 1.0));
    try C.expectApproxEq(b.add(a), C.init(1.6, 0.7, 1.0));
    try C.expectApproxEq(C.add(a, b), C.init(1.6, 0.7, 1.0));
}

// Scenario: Subtracting colors
//   Given c1 ← color(0.9, 0.6, 0.75)
//     And c2 ← color(0.7, 0.1, 0.25)
//    Then c1 - c2 = color(0.2, 0.5, 0.5)
test "subtracting colors" {
    const a = C.init(0.9, 0.6, 0.75);
    const b = C.init(0.7, 0.1, 0.25);

    try C.expectApproxEq(a.sub(b), C.init(0.2, 0.5, 0.5));
    try C.expectApproxEq(b.sub(a), C.init(-0.2, -0.5, -0.5));
    try C.expectApproxEq(C.sub(a, b), C.init(0.2, 0.5, 0.5));
}

// Scenario: Multiplying a color by a scalar
//   Given c ← color(0.2, 0.3, 0.4)
//   Then c * 2 = color(0.4, 0.6, 0.8)
test "multiplying a color by a scalar" {
    const a = C.init(0.2, 0.3, 0.4);
    try C.expectApproxEq(a.mul(2.0), C.init(0.4, 0.6, 0.8));
}

// Scenario: Multiplying colors
//   Given c1 ← color(1, 0.2, 0.4)
//     And c2 ← color(0.9, 1, 0.1)
//    Then c1 * c2 = color(0.9, 0.2, 0.04)
test "multiplying colors" {
    const c1 = C.init(1, 0.2, 0.4);
    const c2 = C.init(0.9, 1, 0.1);
    try C.expectApproxEq(c1.mulC(c2), C.init(0.9, 0.2, 0.04));
    try C.expectApproxEq(c2.mulC(c1), C.init(0.9, 0.2, 0.04));
    try C.expectApproxEq(C.mulC(c1, c2), C.init(0.9, 0.2, 0.04));
}

// Scenario: Reflecting a vector approaching at 45°
//   Given v ← vector(1, -1, 0)
//     And n ← vector(0, 1, 0)
//   When r ← reflect(v, n)
//   Then r = vector(1, 1, 0)

// Scenario: Reflecting a vector off a slanted surface
//   Given v ← vector(0, -1, 0)
//     And n ← vector(√2/2, √2/2, 0)
//   When r ← reflect(v, n)
//   Then r = vector(1, 0, 0)
