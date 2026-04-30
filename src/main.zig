const std = @import("std");
const Io = std.Io;

const rl = @import("raylib");
const core = @import("core.zig");
const drawing = @import("drawing.zig");
const Game = @import("Game.zig");
const Board = @import("Board.zig");
const NextDisplay = @import("NextDisplay.zig");

pub fn main(init: std.process.Init) !void {
    std.debug.print("Welcome to Zig Tetris!", .{});

    const rng_impl: std.Random.IoSource = .{ .io = init.io };
    const rng = rng_impl.interface();

    var board: Board = .init(.{ .x = 32, .y = 128 });
    var next_display: NextDisplay = .init(.{
        .x = 400,
        .y = 128,
        .width = 196,
        .height = 196,
    });

    var game: Game = .init(rng, &board, &next_display);
    game.startPlaying();

    // ---Raylib---

    const screen_bounds: core.Rectangle = .{ .x = 0, .y = 0, .width = 632, .height = 1000 - 32 };
    const screen_width = 632;
    const screen_height = 1000 - 32;
    const header_bounds: core.Rectangle = .{
        .x = screen_width / 2 - 200,
        .y = 32,
        .width = 400,
        .height = 32,
    };
    const game_over_bounds = screen_bounds.withSizeKeepingCenter(320, 120);

    rl.initWindow(screen_width, screen_height, "Zig Tetris");
    defer rl.closeWindow();

    const refresh_rate = rl.getMonitorRefreshRate(0);
    std.debug.print("Refresh rate: {}\n", .{refresh_rate});
    rl.setTargetFPS(refresh_rate);

    // Main game loop
    while (!rl.windowShouldClose()) {
        // ---Game logic---
        const delta_time = rl.getFrameTime();
        game.update(delta_time);

        // ---Draw---
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.black);
        drawing.drawTextCentered("ZIG TETRIS", header_bounds, 32, .white);
        board.draw();
        next_display.draw();

        if (game.state == .game_over) {
            rl.drawRectangle(game_over_bounds.x, game_over_bounds.y, game_over_bounds.width, game_over_bounds.height, .black);
            drawing.drawTextCentered("GAME OVER", game_over_bounds, 40, .red);
        }
    }
}
