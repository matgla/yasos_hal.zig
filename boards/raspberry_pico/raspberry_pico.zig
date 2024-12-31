const std = @import("std");
const builtin = @import("builtin");

pub const hal = @import("hal");

pub const uart = struct {
    const Uart0 = hal.uart.Uart(0, .{ .tx = 0, .rx = 1 }, hal.internal.Uart);

    pub const instance = [_]@TypeOf(Uart0.create()){
        Uart0.create(),
    };
};
