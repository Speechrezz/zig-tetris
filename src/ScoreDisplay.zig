const std = @import("std");
const rl = @import("raylib");
const core = @import("core.zig");
const drawing = @import("drawing.zig");

bounds: core.Rectangle,

score: usize = 0,
score_str: [:0]u8 = undefined,
score_buffer: [10]u8 = undefined,

level: usize = 1,
level_str: [:0]u8 = undefined,
level_buffer: [10]u8 = undefined,

pub fn init(bounds: core.Rectangle) @This() {
    return .{
        .bounds = bounds,
    };
}

pub fn draw(self: *const @This()) void {
    rl.drawRectangleLines(self.bounds.x, self.bounds.y, self.bounds.width, self.bounds.height, .dark_gray);

    var text_bounds = self.bounds.withSizeKeepingCenter(self.bounds.width, 96);

    drawing.drawTextCentered(self.level_str, text_bounds.removeFromTop(96 / 2), 24, .white);
    drawing.drawTextCentered(self.score_str, text_bounds, 24, .white);
}

fn updateScoreString(self: *@This()) void {
    self.score_str = std.fmt.bufPrintSentinel(&self.score_buffer, "{:0>8}", .{self.score}, 0) catch unreachable;
}

fn updateLevelString(self: *@This()) void {
    self.level_str = std.fmt.bufPrintSentinel(&self.level_buffer, "Lvl {:0>2}", .{self.level}, 0) catch unreachable;
}

pub fn reset(self: *@This()) void {
    self.score = 0;
    self.updateScoreString();

    self.level = 1;
    self.updateLevelString();
}

pub fn addScore(self: *@This(), score: usize) void {
    self.score += score;
    self.updateScoreString();
}

pub fn incrementLevel(self: *@This()) void {
    self.level += 1;
    self.updateLevelString();
}
