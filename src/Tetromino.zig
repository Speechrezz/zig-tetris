const std = @import("std");
const core = @import("core.zig");

const Kind = core.TetrominoKind;
const Position = core.Position;

pub const block_count = 4;
pub const Positions = [block_count]Position;

kind: Kind = .nil,
block_offsets: Positions = undefined,
board_offset: Position = .{},
center_point: Position = .{}, // 2 units per block

pub fn create(kind: Kind) @This() {
    var tetromino: @This() = switch (kind) {
        .nil => unreachable,
        .O => .{
            .block_offsets = .{
                .{ .x = 0, .y = 0 },
                .{ .x = 1, .y = 0 },
                .{ .x = 0, .y = 1 },
                .{ .x = 1, .y = 1 },
            },
            .center_point = .{ .x = 1, .y = 1 },
        },
        .I => .{
            .block_offsets = .{
                .{ .x = 0, .y = 0 },
                .{ .x = 1, .y = 0 },
                .{ .x = 2, .y = 0 },
                .{ .x = 3, .y = 0 },
            },
            .center_point = .{ .x = 3, .y = 1 },
        },
        .S => .{
            .block_offsets = .{
                .{ .x = 0, .y = 1 },
                .{ .x = 1, .y = 1 },
                .{ .x = 1, .y = 0 },
                .{ .x = 2, .y = 0 },
            },
            .center_point = .{ .x = 2, .y = 2 },
        },
        .Z => .{
            .block_offsets = .{
                .{ .x = 0, .y = 0 },
                .{ .x = 1, .y = 0 },
                .{ .x = 1, .y = 1 },
                .{ .x = 2, .y = 1 },
            },
            .center_point = .{ .x = 2, .y = 2 },
        },
        .L => .{
            .block_offsets = .{
                .{ .x = 0, .y = 1 },
                .{ .x = 0, .y = 0 },
                .{ .x = 1, .y = 0 },
                .{ .x = 2, .y = 0 },
            },
            .center_point = .{ .x = 2, .y = 0 },
        },
        .J => .{
            .block_offsets = .{
                .{ .x = 0, .y = 0 },
                .{ .x = 1, .y = 0 },
                .{ .x = 2, .y = 0 },
                .{ .x = 2, .y = 1 },
            },
            .center_point = .{ .x = 2, .y = 0 },
        },
        .T => .{
            .block_offsets = .{
                .{ .x = 0, .y = 0 },
                .{ .x = 1, .y = 0 },
                .{ .x = 2, .y = 0 },
                .{ .x = 1, .y = 1 },
            },
            .center_point = .{ .x = 2, .y = 0 },
        },
    };

    tetromino.kind = kind;
    return tetromino;
}

pub fn computeBoardPositions(self: *const @This()) Positions {
    var positions: Positions = undefined;

    for (0..block_count) |i| {
        positions[i].x = self.block_offsets[i].x + self.board_offset.x;
        positions[i].y = self.block_offsets[i].y + self.board_offset.y;
    }

    return positions;
}

pub fn rotateClockwise(self: @This()) @This() {
    var rotated = self;

    for (&rotated.block_offsets) |*offset| {
        offset.x *= 2;
        offset.y *= 2;

        offset.x -= self.center_point.x;
        offset.y -= self.center_point.y;

        const x_temp = offset.x;
        offset.x = -offset.y;
        offset.y = x_temp;

        offset.x += self.center_point.x;
        offset.y += self.center_point.y;

        offset.x = @divTrunc(offset.x, 2);
        offset.y = @divTrunc(offset.y, 2);
    }

    return rotated;
}
