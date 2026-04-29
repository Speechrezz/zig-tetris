const std = @import("std");
const Io = std.Io;

const rl = @import("raylib");
const Game = @import("Game.zig");
const Board = @import("Board.zig");

pub fn main(init: std.process.Init) !void {
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // In order to do I/O operations need an `Io` instance.
    const io = init.io;
    _ = io;

    var board: Board = .init();
    var game: Game = .init(&board);

    board.atPos(0, 20).* = .{ .kind = .I };

    game.floating_blocks = [_]usize{undefined} ** 4;
    game.floating_blocks = .{
        Board.idxFromPos(1, 10),
        Board.idxFromPos(2, 10),
        Board.idxFromPos(1, 11),
        Board.idxFromPos(2, 11),
    };

    for (game.floating_blocks.?) |idx| {
        board.blocks[idx] = .{ .kind = .O, .is_floating = true };
    }

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
        board.draw(0, 0);
    }
}
