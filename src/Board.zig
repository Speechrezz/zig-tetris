const std = @import("std");
const rl = @import("raylib");

const ncast = @import("core.zig").ncast;
const Block = @import("Block.zig");

const board_width = 10;
const board_height = 25;
const block_count = board_width * board_height;
const block_size = Block.block_size;

const outline_width = 1;
const pixel_width = board_width * block_size + 2 * outline_width;
const pixel_height = board_height * block_size + 2 * outline_width;

blocks: [block_count]Block = [_]Block{.{}} ** block_count,

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
