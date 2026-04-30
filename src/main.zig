const std = @import("std");
const Io = std.Io;

const rl = @import("raylib");
const Game = @import("Game.zig");
const Board = @import("Board.zig");

pub fn main(init: std.process.Init) !void {
    std.debug.print("Welcome to Zig Tetris!", .{});

    const rng_impl: std.Random.IoSource = .{ .io = init.io };
    const rng = rng_impl.interface();

    var board: Board = .init(.{ .x = 0, .y = 0 });
    var game: Game = .init(rng, &board);

    game.spawnNewTetromino();

    // ---Raylib---

    const screenWidth = 800;
    const screenHeight = 1000;

    rl.initWindow(screenWidth, screenHeight, "Zig Tetris");
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
        board.draw();
    }
}
