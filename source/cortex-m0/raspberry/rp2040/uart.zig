//
// uart.zig
//
// Copyright (C) 2024 Mateusz Stadnik <matgla@live.com>
//
// This program is free software: you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation, either version
// 3 of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be
// useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
// PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General
// Public License along with this program. If not, see
// <https://www.gnu.org/licenses/>.
//

const std = @import("std");
const uart = @cImport({
    @cInclude("hardware/uart.h");
    @cInclude("hardware/gpio.h");
});

pub const Uart = struct {
    fd: i32,
    initialized: bool,

    pub fn init(_: Uart) void {
        _ = uart.uart_init(@ptrFromInt(uart.UART0_BASE), 115200);
        // self.initialized = baudrate != 0;
        uart.gpio_set_function(0, uart.GPIO_FUNC_UART);
        uart.gpio_set_function(1, uart.GPIO_FUNC_UART);
    }

    pub fn write(_: Uart, data: []const u8) !void {
        uart.uart_write_blocking(@ptrFromInt(uart.UART0_BASE), data.ptr, data.len);
        uart.uart_tx_wait_blocking(@ptrFromInt(uart.UART0_BASE));
    }
};
