const std = @import("std");
const rl = @import("raylib");
const core = @import("core.zig");
const drawing = @import("drawing.zig");
const Tetromino = @import("Tetromino.zig");

const Position = core.Position;
const ncast = core.ncast;
const TetrominoKind = core.TetrominoKind;

pub const board_width = 10;
pub const board_height = 25;
pub const block_size = drawing.block_size;
pub const block_count = board_width * board_height;

const outline_width = drawing.outline_width;
const pixel_width = board_width * block_size;
const pixel_height = board_height * block_size;

pos: Position,
blocks: [block_count]TetrominoKind = [_]TetrominoKind{.nil} ** block_count,
active_tetromino: ?Tetromino = null,

pub fn init(board_pos: Position) @This() {
    return .{
        .pos = board_pos,
    };
}

pub fn reset(self: *@This()) void {
    self.blocks = [_]TetrominoKind{.nil} ** block_count;
    self.active_tetromino = null;
}

pub fn draw(self: *const @This()) void {
    rl.drawRectangleLines(self.pos.x, self.pos.y, pixel_width, pixel_height, .dark_gray);

    for (0..board_width) |i| {
        for (0..board_height) |j| {
            const idx = i + j * board_width;
            const x: i32 = @intCast(i);
            const y: i32 = @intCast(j);
            self.drawBlockAt(self.blocks[idx], x, y);
        }
    }

    if (self.active_tetromino) |tetromino| {
        const positions = tetromino.computeBoardPositions();
        for (positions) |pos| {
            self.drawBlockAt(tetromino.kind, pos.x, pos.y);
        }

        // Draw debug rotation point
        if (false) {
            var x = (tetromino.center_point.x + 1) * (block_size / 2);
            var y = (tetromino.center_point.y + 1) * (block_size / 2);

            x += tetromino.board_offset.x * block_size + self.pos.x;
            y += tetromino.board_offset.y * block_size + self.pos.y;

            rl.drawCircle(x, y, 4.0, .white);
        }
    }
}

pub fn drawBlockAt(self: *const @This(), kind: TetrominoKind, x: i32, y: i32) void {
    const global_x = x * block_size + self.pos.x;
    const global_y = y * block_size + self.pos.y;
    drawing.drawBlockAt(kind, global_x, global_y);
}

pub fn atPos(self: *@This(), x: i32, y: i32) *TetrominoKind {
    return &self.blocks[idxFromPos(x, y)];
}

pub fn idxFromPos(x: i32, y: i32) usize {
    return @intCast(x + y * board_width);
}

pub fn idxFromRow(row: usize) usize {
    return row * board_width;
}

pub fn isSolidAt(self: *const @This(), x: i32, y: i32) bool {
    if (x < 0 or x >= board_width) return true;
    if (y < 0 or y >= board_height) return true;

    return self.blocks[idxFromPos(x, y)].isSolid();
}

pub fn isRowFull(self: *const @This(), idx: usize) bool {
    for (0..board_width) |x| {
        if (self.blocks[x + idx].isEmpty()) {
            return false;
        }
    }

    return true;
}
