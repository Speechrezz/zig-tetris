const std = @import("std");
const rl = @import("raylib");

const ncast = @import("core.zig").ncast;
const Block = @import("Block.zig");

pub const board_width = 10;
pub const board_height = 25;
pub const block_count = board_width * board_height;
pub const block_size = Block.block_size;

const outline_width = 1;
const pixel_width = board_width * block_size + 2 * outline_width;
const pixel_height = board_height * block_size + 2 * outline_width;

blocks: [block_count]Block = [_]Block{.empty} ** block_count,

pub fn init() @This() {
    return .{};
}

pub fn draw(self: *const @This(), x_offset: i32, y_offset: i32) void {
    rl.drawRectangleLines(x_offset, y_offset, pixel_width, pixel_height, .dark_gray);

    for (0..board_width) |i| {
        for (0..board_height) |j| {
            const idx = i + j * board_width;
            const x = x_offset + outline_width + ncast(i32, i) * block_size;
            const y = y_offset + outline_width + ncast(i32, j) * block_size;
            self.blocks[idx].draw(x, y);
        }
    }
}

pub fn atPos(self: *@This(), x: i32, y: i32) *Block {
    return &self.blocks[idxFromPos(x, y)];
}

pub fn idxFromPos(x: i32, y: i32) usize {
    return @intCast(x + y * board_width);
}

fn isSolid(self: *const @This(), idx: usize) bool {
    const block = self.blocks[idx];
    const is_empty = block.kind == .empty;
    const is_floating = block.is_floating;
    return !is_empty and !is_floating;
}

pub fn isSolidDown(self: *const @This(), idx: usize) bool {
    // End of board
    if (idx >= block_count - board_width) return true;

    return self.isSolid(idx + board_width);
}

pub fn isSolidLeft(self: *const @This(), idx: usize) bool {
    // End of board
    const x = @mod(idx, board_width);
    if (x == 0) return true;

    return self.isSolid(idx - 1);
}

pub fn isSolidRight(self: *const @This(), idx: usize) bool {
    // End of board
    const x = @mod(idx, board_width);
    if (x == board_width - 1) return true;

    return self.isSolid(idx + 1);
}
