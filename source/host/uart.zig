const std = @import("std");

pub const Uart = struct {
    fd: i32,

    pub fn write(uart: Uart, data: []const u8) !void {
        _ = try std.posix.write(uart.fd, data);
    }
};
