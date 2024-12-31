const std = @import("std");

pub const hal = @import("hal");

pub const uart = struct {
    const StdoutUart = hal.uart.Uart(std.posix.STDOUT_FILENO, .{}, hal.internal.Uart);
    pub const instance = [_]@TypeOf(StdoutUart.create()){
        StdoutUart.create(),
    };

    pub fn hasNum(comptime x: comptime_int) bool {
        return x < instance.len;
    }
};
