const std = @import("std");
const rl = @import("raylib");
const core = @import("core.zig");
const Board = @import("Board.zig");
const Tetromino = @import("Tetromino.zig");

const fast_drop_period = 0.04;

rng: std.Random,
board: *Board,
drop_period: f32 = 1.0, // In seconds
time_passed: f32 = 0.0, // In seconds

pub fn init(rng: std.Random, board: *Board) @This() {
    return .{
        .rng = rng,
        .board = board,
    };
}

pub fn update(self: *@This(), delta_time: f32) void {
    self.handleInput();

    // Move pieces down
    self.time_passed += delta_time;
    const drop_period = if (rl.isKeyDown(.down)) fast_drop_period else self.drop_period;

    if (rl.isKeyPressed(.down)) {
        self.time_passed = fast_drop_period;
    }

    if (self.time_passed >= drop_period) {
        self.time_passed -= drop_period;

        if (self.board.active_tetromino) |*active_tetromino| {
            self.moveDown(active_tetromino);
        }
    }
}

fn handleInput(self: *@This()) void {
    if (self.board.active_tetromino) |*tetromino| {
        if (rl.isKeyPressed(.up)) {
            self.rotateClockwise(tetromino);
        }

        if (rl.isKeyPressed(.left)) {
            self.moveLeft(tetromino);
        }

        if (rl.isKeyPressed(.right)) {
            self.moveRight(tetromino);
        }
    }
}

pub fn spawnNewTetromino(self: *@This()) void {
    const rand = self.rng.intRangeLessThan(i32, 1, core.TetrominoKinds);
    const kind: core.TetrominoKind = @enumFromInt(rand);
    std.debug.print("rand={}, kind={}\n", .{ kind, rand });

    var tetromino: Tetromino = .create(kind);
    // const center_x = @divTrunc(tetromino.center_point.x, 2);
    tetromino.board_offset.x = @divTrunc(Board.board_width, 2);

    const positions = tetromino.computeBoardPositions();
    if (self.hasTetrominoCollided(positions, 0, 0)) {
        std.debug.print("TODO: GAME OVER!\n", .{});
    }

    self.board.active_tetromino = tetromino;
}

fn tetrominoPlaced(self: *@This()) void {
    for (0..Board.board_height) |row| {
        const idx = Board.idxFromRow(row);
        if (self.board.isRowFull(idx)) {
            const offset = Board.board_width;
            @memmove(self.board.blocks[offset .. idx + offset], self.board.blocks[0..idx]);
        }
    }

    self.spawnNewTetromino();
}

fn hasTetrominoCollided(self: *@This(), positions: Tetromino.Positions, x_offset: i32, y_offset: i32) bool {
    var has_collided = false;

    for (positions) |pos| {
        const x = pos.x + x_offset;
        const y = pos.y + y_offset;
        has_collided = has_collided or self.board.isSolidAt(x, y);
    }

    return has_collided;
}

fn rotateClockwise(self: *@This(), tetromino: *Tetromino) void {
    const rotated = tetromino.rotateClockwise();

    const positions = rotated.computeBoardPositions();
    if (self.hasTetrominoCollided(positions, 0, 0)) {
        // TODO: try wall-kick
        return;
    }

    tetromino.* = rotated;
}

fn moveDown(self: *@This(), tetromino: *Tetromino) void {
    const positions = tetromino.computeBoardPositions();

    if (self.hasTetrominoCollided(positions, 0, 1)) {
        for (positions) |pos| {
            self.board.atPos(pos.x, pos.y).* = tetromino.kind;
        }

        self.tetrominoPlaced();
        return;
    }

    tetromino.board_offset.y += 1;
}

fn moveLeft(self: *@This(), tetromino: *Tetromino) void {
    const positions = tetromino.computeBoardPositions();
    if (self.hasTetrominoCollided(positions, -1, 0)) return;

    tetromino.board_offset.x -= 1;
}

fn moveRight(self: *@This(), tetromino: *Tetromino) void {
    const positions = tetromino.computeBoardPositions();
    if (self.hasTetrominoCollided(positions, 1, 0)) return;

    tetromino.board_offset.x += 1;
}
