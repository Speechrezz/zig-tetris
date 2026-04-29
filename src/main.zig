const std = @import("std");
const Io = std.Io;

const rl = @import("raylib");
const Board = @import("Board.zig");

pub fn main(init: std.process.Init) !void {
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // In order to do I/O operations need an `Io` instance.
    const io = init.io;
    _ = io;

    var board: Board = .init();
    board.blocks[40] = .{ .kind = .I };
    board.blocks[41] = .{ .kind = .S };

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
        // TODO

        // ---Draw---
        rl.beginDrawing();
        defer rl.endDrawing();
        const delta_time = rl.getFrameTime();
        _ = delta_time;

        rl.clearBackground(.black);
        board.draw(0, 0);
    }
}
