const std = @import("std");

const board = @import("board");

pub export fn main() void {
    var uart = board.uart.instance[0];
    try uart.init(.{
        .baudrate = 115200,
    });

    _ = uart.writer().write("Hello from Uart 0\n") catch unreachable;
    while (true) {}
}
