const std = @import("std");
const uart = @cImport({
    @cInclude("hardware/uart.h");
});

pub const Uart = struct {
    fd: i32,

    pub fn write(_: Uart, _: []const u8) !void {
        // uart.uart_init(uart.uart0, 115200);
    }
};
