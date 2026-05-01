const std = @import("std");
const core = @import("core.zig");

pub const attempts = 4;
pub const AttemptList = [attempts]core.Position;

pub const Context = struct {
    kind: core.TetrominoKind,
    rotation_start: u8,
    rotation_end: u8,
};

pub fn getOffsets(context: Context) AttemptList {
    if (context.kind == .I) {
        return getOffsetsI(context);
    }
    return getOffsetsGeneric(context);
}

fn intFromRotations(start: u8, end: u8) u8 {
    return start + (end << 2);
}

fn getOffsetsGeneric(context: Context) AttemptList {
    const rotation = intFromRotations(context.rotation_start, context.rotation_end);

    return switch (rotation) {
        else => unreachable,

        // Clockwise
        intFromRotations(0, 1) => .{ // 0 -> R
            .{ .x = -1, .y = 0 },
            .{ .x = -1, .y = 1 },
            .{ .x = 0, .y = -2 },
            .{ .x = -1, .y = -2 },
        },
        intFromRotations(1, 2) => .{ // R -> 2
            .{ .x = 1, .y = 0 },
            .{ .x = 1, .y = -1 },
            .{ .x = 0, .y = 2 },
            .{ .x = 1, .y = 2 },
        },
        intFromRotations(2, 3) => .{ // 2 -> L
            .{ .x = 1, .y = 0 },
            .{ .x = 1, .y = 1 },
            .{ .x = 0, .y = -2 },
            .{ .x = 1, .y = -2 },
        },
        intFromRotations(3, 0) => .{ // L -> 0
            .{ .x = -1, .y = 0 },
            .{ .x = -1, .y = -1 },
            .{ .x = 0, .y = 2 },
            .{ .x = -1, .y = 2 },
        },

        // Counter-clockwise
        intFromRotations(0, 3) => .{ // 0 -> L
            .{ .x = 1, .y = 0 },
            .{ .x = 1, .y = 1 },
            .{ .x = 0, .y = -2 },
            .{ .x = 1, .y = -2 },
        },
        intFromRotations(3, 2) => .{ // L -> 2
            .{ .x = -1, .y = 0 },
            .{ .x = -1, .y = -1 },
            .{ .x = 0, .y = 2 },
            .{ .x = -1, .y = 2 },
        },
        intFromRotations(2, 1) => .{ // 2 -> R
            .{ .x = -1, .y = 0 },
            .{ .x = -1, .y = 1 },
            .{ .x = 0, .y = -2 },
            .{ .x = -1, .y = -2 },
        },
        intFromRotations(1, 0) => .{ // R -> 0
            .{ .x = 1, .y = 0 },
            .{ .x = 1, .y = -1 },
            .{ .x = 0, .y = 2 },
            .{ .x = 1, .y = 2 },
        },
    };
}

fn getOffsetsI(context: Context) AttemptList {
    const rotation = intFromRotations(context.rotation_start, context.rotation_end);

    return switch (rotation) {
        else => unreachable,

        // Clockwise
        intFromRotations(0, 1) => .{ // 0 -> R
            .{ .x = -2, .y = 0 },
            .{ .x = 1, .y = 0 },
            .{ .x = -2, .y = -1 },
            .{ .x = 1, .y = 2 },
        },
        intFromRotations(1, 2) => .{ // R -> 2
            .{ .x = -1, .y = 0 },
            .{ .x = 2, .y = 0 },
            .{ .x = -1, .y = 2 },
            .{ .x = 2, .y = -1 },
        },
        intFromRotations(2, 3) => .{ // 2 -> L
            .{ .x = 2, .y = 0 },
            .{ .x = -1, .y = 0 },
            .{ .x = 2, .y = 1 },
            .{ .x = -1, .y = -2 },
        },
        intFromRotations(3, 0) => .{ // L -> 0
            .{ .x = 1, .y = 0 },
            .{ .x = -2, .y = 0 },
            .{ .x = 1, .y = -2 },
            .{ .x = -2, .y = 1 },
        },

        // Counter-clockwise
        intFromRotations(0, 3) => .{ // 0 -> L
            .{ .x = -1, .y = 0 },
            .{ .x = 2, .y = 0 },
            .{ .x = -1, .y = 2 },
            .{ .x = 2, .y = -1 },
        },
        intFromRotations(3, 2) => .{ // L -> 2
            .{ .x = -2, .y = 0 },
            .{ .x = 1, .y = 0 },
            .{ .x = -2, .y = -1 },
            .{ .x = 1, .y = 2 },
        },
        intFromRotations(2, 1) => .{ // 2 -> R
            .{ .x = 1, .y = 0 },
            .{ .x = -2, .y = 0 },
            .{ .x = 1, .y = -2 },
            .{ .x = -2, .y = 1 },
        },
        intFromRotations(1, 0) => .{ // R -> 0
            .{ .x = 2, .y = 0 },
            .{ .x = -1, .y = 0 },
            .{ .x = 2, .y = 1 },
            .{ .x = -1, .y = -2 },
        },
    };
}
