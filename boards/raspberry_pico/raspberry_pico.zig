const std = @import("std");
const builtin = @import("builtin");

pub const hal = @import("hal");

pub const uart = struct {
    pub const instance = [_]hal.Uart{
        hal.Uart{ .fd = 0 },
    };

    pub fn hasNum(comptime x: comptime_int) bool {
        return x < instance.len;
    }
};
