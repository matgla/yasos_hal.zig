const std = @import("std");

const board = @import("board");
const _ = @import("board")._exit;

pub export fn main() void {
    const uart = board.uart.instance[0];
    uart.write("Hello from Uart 0\n") catch unreachable;

    if (comptime board.uart.hasNum(1)) {
        const uart2 = board.uart.instance[1];
        uart2.write("Hello from Uart 1\n") catch unreachable;
    }
}
