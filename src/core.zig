/// numeric cast convenience function
pub fn ncast(comptime T: type, value: anytype) T {
    const in_type = @typeInfo(@TypeOf(value));
    const out_type = @typeInfo(T);

    if (in_type == .int and out_type == .float) {
        return @floatFromInt(value);
    }
    if (in_type == .float and out_type == .int) {
        return @trunc(value);
    }
    if (in_type == .int and out_type == .int) {
        return @intCast(value);
    }
    if (in_type == .float and out_type == .float) {
        return @floatCast(value);
    }
    @compileError("unexpected in_type '" ++ @typeName(@TypeOf(value)) ++ "' and out_type '" ++ @typeName(T) ++ "'");
}

pub const Position = struct {
    x: i32 = 0,
    y: i32 = 0,
};

pub const Rectangle = struct {
    x: i32 = 0,
    y: i32 = 0,
    width: i32 = 0,
    height: i32 = 0,

    pub fn getCenterX(self: @This()) i32 {
        return self.x + @divTrunc(self.width, 2);
    }
    pub fn getCenterY(self: @This()) i32 {
        return self.y + @divTrunc(self.height, 2);
    }
};

pub const TetrominoKind = enum {
    nil,
    O,
    I,
    S,
    Z,
    L,
    J,
    T,

    pub fn isEmpty(self: @This()) bool {
        return self == .nil;
    }

    pub fn isSolid(self: @This()) bool {
        return self != .nil;
    }
};

pub const TetrominoKinds = 7;
