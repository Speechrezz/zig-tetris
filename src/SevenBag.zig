const std = @import("std");
const core = @import("core.zig");

const length = core.TetrominoKinds;

rng: std.Random,
sequence: [length]u8 = undefined,
sequence_idx: usize = length,

pub fn init(rng: std.Random) @This() {
    return .{
        .rng = rng,
    };
}

pub fn getNext(self: *@This()) u8 {
    if (self.sequence_idx >= length) {
        self.reset();
    }

    self.sequence_idx += 1;
    return self.sequence[self.sequence_idx - 1];
}

pub fn reset(self: *@This()) void {
    var buffer: [length]u8 = undefined;
    for (0..length) |i| {
        buffer[i] = @intCast(i);
    }

    var bag: std.ArrayList(u8) = .initBuffer(&buffer);
    bag.items.len = length;

    for (0..length) |i| {
        const bag_idx = self.rng.intRangeLessThan(usize, 0, bag.items.len);
        self.sequence[i] = bag.swapRemove(bag_idx);
    }

    self.sequence_idx = 0;
}

test {
    const io = std.testing.io;

    const rng_impl: std.Random.IoSource = .{ .io = io };
    const rng = rng_impl.interface();

    var seven_bag: @This() = .init(rng);

    for (0..2 * length) |_| {
        const v = seven_bag.getNext();
        std.debug.print("{}, ", .{v});
    }

    std.debug.print("\n", .{});
}
