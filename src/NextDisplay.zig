const std = @import("std");
const rl = @import("raylib");
const drawing = @import("drawing.zig");
const core = @import("core.zig");
const Tetromino = @import("Tetromino.zig");

const Position = core.Position;
const Rectangle = core.Rectangle;

bounds: Rectangle = .{},
tetromino: ?Tetromino = null,

pub fn init(bounds: Rectangle) @This() {
    return .{
        .bounds = bounds,
    };
}

pub fn draw(self: *const @This()) void {
    rl.drawRectangleLines(self.bounds.x, self.bounds.y, self.bounds.width, self.bounds.height, .dark_gray);

    if (self.tetromino) |tetromino| {
        const center_x = self.bounds.getCenterX();
        const center_y = self.bounds.getCenterY();

        const offset_x = center_x - (tetromino.center_point.x + 1) * (drawing.block_size / 2);
        const offset_y = center_y - (tetromino.center_point.y + 1) * (drawing.block_size / 2);

        for (tetromino.block_offsets) |offset| {
            const x = offset_x + offset.x * drawing.block_size;
            const y = offset_y + offset.y * drawing.block_size;
            drawing.drawBlockAt(tetromino.kind, x, y);
        }
    }
}
