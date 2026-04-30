const std = @import("std");
const rl = @import("raylib");
const core = @import("core.zig");
const TetrominoKind = core.TetrominoKind;

pub const block_size = 32;
pub const outline_width = 1;

pub fn drawBlockAt(kind: TetrominoKind, x: i32, y: i32) void {
    const color: rl.Color = switch (kind) {
        .nil => return,
        .O => .yellow,
        .I => .sky_blue,
        .S => .green,
        .Z => .red,
        .L => .orange,
        .J => .dark_blue,
        .T => .magenta,
    };

    const adjusted_x = x + outline_width;
    const adjusted_y = y + outline_width;
    const adjusted_size = block_size - 2 * outline_width;
    rl.drawRectangle(adjusted_x, adjusted_y, adjusted_size, adjusted_size, color);
}

pub fn drawTextCentered(text: [:0]const u8, bounds: core.Rectangle, font_size: i32, color: rl.Color) void {
    const text_width = rl.measureText(text, font_size);

    const x = bounds.getCenterX() - @divTrunc(text_width, 2);
    const y = bounds.getCenterY() - @divTrunc(font_size, 2);

    rl.drawText(text, x, y, font_size, color);
}
