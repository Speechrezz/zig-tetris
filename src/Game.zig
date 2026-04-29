const std = @import("std");
const rl = @import("raylib");
const Board = @import("Board.zig");
const Block = @import("Block.zig");

const tetromino_block_count = 4;
const IndexArray = [tetromino_block_count]usize;

board: *Board,
drop_period: f32 = 1.0, // In seconds
time_passed: f32 = 0.0, // In seconds

floating_blocks: ?IndexArray = null,

pub fn init(board: *Board) @This() {
    return .{
        .board = board,
    };
}

pub fn update(self: *@This(), delta_time: f32) void {
    self.handleInput();

    // Move pieces down
    self.time_passed += delta_time;
    if (self.time_passed >= self.drop_period) {
        self.time_passed -= self.drop_period;

        if (self.floating_blocks) |*floating_blocks| {
            self.moveDown(floating_blocks);
        }
    }
}

fn handleInput(self: *@This()) void {
    if (self.floating_blocks) |*blocks| {
        if (rl.isKeyPressed(.left)) {
            self.moveLeft(blocks);
        }
        if (rl.isKeyPressed(.right)) {
            self.moveRight(blocks);
        }
    }
}

fn moveDown(self: *@This(), blocks: *IndexArray) void {
    var has_collided = false;
    for (blocks) |idx| {
        has_collided = has_collided or self.board.isSolidDown(idx);
    }

    if (has_collided) {
        self.floating_blocks = null;
        for (blocks) |idx| {
            self.board.blocks[idx].is_floating = false;
        }

        std.debug.print("[moveDown] TODO: has stopped\n", .{});
        return;
    }

    const temp_block = self.board.blocks[self.floating_blocks.?[0]];

    for (blocks) |idx| {
        self.board.blocks[idx] = .empty;
    }

    for (blocks) |*idx| {
        idx.* += Board.board_width;
        self.board.blocks[idx.*] = temp_block;
    }
}

fn moveLeft(self: *@This(), blocks: *IndexArray) void {
    var has_collided = false;
    for (blocks) |idx| {
        has_collided = has_collided or self.board.isSolidLeft(idx);
    }

    if (has_collided) return;

    const temp_block = self.board.blocks[self.floating_blocks.?[0]];

    for (blocks) |idx| {
        self.board.blocks[idx] = .empty;
    }

    for (blocks) |*idx| {
        idx.* -= 1;
        self.board.blocks[idx.*] = temp_block;
    }
}

fn moveRight(self: *@This(), blocks: *IndexArray) void {
    var has_collided = false;
    for (blocks) |idx| {
        has_collided = has_collided or self.board.isSolidRight(idx);
    }

    if (has_collided) return;

    const temp_block = self.board.blocks[self.floating_blocks.?[0]];

    for (blocks) |idx| {
        self.board.blocks[idx] = .empty;
    }

    for (blocks) |*idx| {
        idx.* += 1;
        self.board.blocks[idx.*] = temp_block;
    }
}
