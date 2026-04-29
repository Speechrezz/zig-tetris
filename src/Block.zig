const std = @import("std");
const rl = @import("raylib");

pub const block_size = 32;
pub const Kind = enum { empty, O, I, S, Z, L, J, T };

const outline_width = 1;

kind: Kind = .empty,

pub const empty: @This() = .{};

pub fn draw(self: @This(), x: i32, y: i32) void {
    const color: rl.Color = switch (self.kind) {
        .empty => return,
        .O => .yellow,
        .I => .sky_blue,
        .S => .red,
        .Z => .green,
        .L => .orange,
        .J => .pink,
        .T => .purple,
    };

    const adjusted_size = block_size - 2 * outline_width;
    rl.drawRectangle(x + outline_width, y + outline_width, adjusted_size, adjusted_size, color);
}
