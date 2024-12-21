const std = @import("std");

pub const hal = @import("hal");

pub const uart = struct {
    pub const instance = [_]hal.Uart{
        hal.Uart{
            .fd = std.posix.STDOUT_FILENO,
        },
        hal.Uart{
            .fd = std.posix.STDERR_FILENO,
        },
    };

    pub fn hasNum(comptime x: comptime_int) bool {
        return x < instance.len;
    }
};
