const std = @import("std");

// costs 0.5ms / 100,000 generation more than Xoroshiro128
const rand = std.crypto.random;

//var r = std.rand.Xoroshiro128.init(534532);
//var rand = r.random();

// 1/3500 chance of having a dupe if we have 100,000,000 things of the same type.
// reading 100M from two tables would take ~1.41 seconds and take 1GB of ram.
//pub const UuidType = u64;
pub const UuidType = u128;

pub const Uuid = struct {
    value: UuidType,

    const S = @This();
    pub fn new() S {
        return S{
            .value = rand.int(UuidType),
        };
    }

    pub fn eql(s: *const S, other: S) bool {
        return s.value == other.value;
    }

    pub fn zero() S {
        return S{
            .value = 0,
        };
    }
};

test "uuid eq" {
    const one = Uuid.new();
    const two = Uuid.new();

    try std.testing.expect(one.eql(one));
    try std.testing.expect(!one.eql(two));
}

test "uuid zero" {
    const zero = Uuid.zero();
    try std.testing.expectEqual(0, zero.value);
}

const benchmark = @import("benchmark");
test "Uuid create" {
    if (!@import("opts").benchmark) return error.SkipZigTest;

    const b = struct {
        fn bench(ctx: *benchmark.Context) void {
            while (ctx.run()) {
                _ = Uuid.new();
            }
        }
    }.bench;
    benchmark.benchmark("Uuid create", b);
}

