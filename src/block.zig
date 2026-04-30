const rl = @import("raylib");
const core = @import("core.zig");
const TetrominoKind = core.TetrominoKind;

pub const size = 32;
pub const outline_width = 1;

pub fn drawAt(kind: TetrominoKind, x: i32, y: i32) void {
    const color: rl.Color = switch (kind) {
        .nil => return,
        .O => .yellow,
        .I => .sky_blue,
        .S => .red,
        .Z => .green,
        .L => .orange,
        .J => .pink,
        .T => .purple,
    };

    const adjusted_x = x + outline_width;
    const adjusted_y = y + outline_width;
    const adjusted_size = size - 2 * outline_width;
    rl.drawRectangle(adjusted_x, adjusted_y, adjusted_size, adjusted_size, color);
}
