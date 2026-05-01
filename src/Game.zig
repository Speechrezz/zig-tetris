const std = @import("std");
const rl = @import("raylib");
const core = @import("core.zig");
const Board = @import("Board.zig");
const Tetromino = @import("Tetromino.zig");
const NextDisplay = @import("NextDisplay.zig");
const ScoreDisplay = @import("ScoreDisplay.zig");
const SevenBag = @import("SevenBag.zig");
const wall_kick = @import("wall_kick.zig");

const TetrominoKind = core.TetrominoKind;
const GameState = enum {
    main_menu,
    playing,
    game_over,
    paused,
};

const fast_drop_period = 0.04;
const lines_cleared_per_level = 10;

state: GameState = .playing,

seven_bag: SevenBag,
board: *Board,
next_display: *NextDisplay,
score_display: *ScoreDisplay,

drop_period: f32 = 1.0, // In seconds
time_passed: f32 = 0.0, // In seconds
lines_cleared: usize = 0,

pub fn init(rng: std.Random, board: *Board, next_display: *NextDisplay, score_display: *ScoreDisplay) @This() {
    return .{
        .seven_bag = .{ .rng = rng },
        .board = board,
        .next_display = next_display,
        .score_display = score_display,
    };
}

pub fn startPlaying(self: *@This()) void {
    self.state = .playing;
    self.board.reset();
    self.score_display.reset();
    self.lines_cleared = 0;
    self.drop_period = dropPeriodFromLevel(self.score_display.level);

    self.next_display.tetromino = .create(self.chooseNextTetromino());
    _ = self.spawnNewTetromino(self.chooseNextTetromino());
}

pub fn update(self: *@This(), delta_time: f32) void {
    self.handleInput();

    const soft_drop = rl.isKeyDown(.down);

    // Move pieces down
    self.time_passed += delta_time;
    const drop_period = if (soft_drop) fast_drop_period else self.drop_period;

    if (rl.isKeyPressed(.down)) {
        self.time_passed = fast_drop_period;
    }

    if (self.time_passed >= drop_period) {
        self.time_passed -= drop_period;

        if (self.board.active_tetromino) |*active_tetromino| {
            self.moveDown(active_tetromino);

            if (soft_drop) {
                self.score_display.addScore(1);
            }
        }
    }
}

fn handleInput(self: *@This()) void {
    if (self.board.active_tetromino) |*tetromino| {
        if (rl.isKeyPressed(.up) or rl.isKeyPressed(.x)) {
            self.rotateClockwise(tetromino);
        }
        if (rl.isKeyPressed(.z)) {
            self.rotateCounterClockwise(tetromino);
        }

        if (rl.isKeyPressed(.left)) {
            self.moveLeft(tetromino);
        }

        if (rl.isKeyPressed(.right)) {
            self.moveRight(tetromino);
        }
    }

    if (self.state == .game_over) {
        if (rl.isKeyPressed(.enter)) {
            self.startPlaying();
        }
    }
}

fn chooseNextTetromino(self: *@This()) TetrominoKind {
    const rand = self.seven_bag.getNext() + 1;
    return @enumFromInt(rand);
}

fn dropPeriodFromLevel(level: usize) f32 {
    const l: f32 = @floatFromInt(level - 1);
    return std.math.pow(f32, 0.8 - l * 0.007, l);
}

fn incrementLevel(self: *@This()) void {
    if (self.score_display.level >= 15) return;

    self.score_display.incrementLevel();
    self.drop_period = dropPeriodFromLevel(self.score_display.level);
}

fn tetrominoPlaced(self: *@This()) void {
    var rows_cleared: usize = 0;
    for (0..Board.board_height) |row| {
        const idx = Board.idxFromRow(row);
        if (self.board.isRowFull(idx)) {
            rows_cleared += 1;
            const offset = Board.board_width;
            @memmove(self.board.blocks[offset .. idx + offset], self.board.blocks[0..idx]);
        }
    }

    if (rows_cleared > 0) {
        const score: usize = switch (rows_cleared) {
            1 => 100,
            2 => 300,
            3 => 500,
            4 => 800,
            else => unreachable,
        };

        self.score_display.addScore(self.score_display.level * score);

        self.lines_cleared += rows_cleared;
        if (self.lines_cleared >= lines_cleared_per_level) {
            self.lines_cleared -= lines_cleared_per_level;
            self.incrementLevel();
        }
    }

    const next_kind = self.next_display.tetromino.?.kind;
    self.next_display.tetromino = .create(self.chooseNextTetromino());

    if (!self.spawnNewTetromino(next_kind)) {
        self.state = .game_over;
    }
}

fn spawnNewTetromino(self: *@This(), kind: TetrominoKind) bool {
    var tetromino: Tetromino = .create(kind);
    const center_x = tetromino.center_point.x + 1;
    tetromino.board_offset.x = @divTrunc(Board.board_width - center_x, 2);

    const positions = tetromino.computeBoardPositions();
    if (self.hasTetrominoCollided(positions, 0, 0)) {
        self.board.active_tetromino = null;
        return false;
    }

    self.board.active_tetromino = tetromino;
    return true;
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

fn tryRotate(self: *@This(), before: *Tetromino, after: *Tetromino) bool {
    const positions = after.computeBoardPositions();

    if (!self.hasTetrominoCollided(positions, 0, 0)) {
        return true;
    }

    const wall_kick_ctx: wall_kick.Context = .{
        .kind = before.kind,
        .rotation_start = before.rotation_idx,
        .rotation_end = after.rotation_idx,
    };
    const wall_kicks = wall_kick.getOffsets(wall_kick_ctx);

    for (wall_kicks) |offset| {
        if (!self.hasTetrominoCollided(positions, offset.x, -offset.y)) {
            after.board_offset.x += offset.x;
            after.board_offset.y -= offset.y;
            return true;
        }
    }

    return false;
}

fn rotateClockwise(self: *@This(), tetromino: *Tetromino) void {
    var rotated = tetromino.rotateClockwise();

    if (self.tryRotate(tetromino, &rotated)) {
        tetromino.* = rotated;
    }
}

fn rotateCounterClockwise(self: *@This(), tetromino: *Tetromino) void {
    var rotated = tetromino.rotateCounterClockwise();

    if (self.tryRotate(tetromino, &rotated)) {
        tetromino.* = rotated;
    }
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
