//
// system_stubs.zig
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

const c = @cImport({
    @cInclude("hardware/regs/resets.h");
    @cInclude("hardware/resets.h");
});

extern var _data_start: u8;
extern var _data_end: u8;
extern var __data_start_flash__: u8;

fn initialize_data() void {
    const data_start: [*]u8 = @ptrCast(&_data_start);
    const data_end: [*]u8 = @ptrCast(&_data_end);
    const data_len = @intFromPtr(data_end) - @intFromPtr(data_start);
    const data_src: [*]const u8 = @ptrCast(&__data_start_flash__);

    @memcpy(data_start[0..data_len], data_src[0..data_len]);
}

export fn crt_init() void {
    c.reset_block(~(c.RESETS_RESET_IO_QSPI_BITS | c.RESETS_RESET_PADS_QSPI_BITS |
        c.RESETS_RESET_PLL_USB_BITS | c.RESETS_RESET_USBCTRL_BITS | c.RESETS_RESET_SYSCFG_BITS |
        c.RESETS_RESET_PLL_SYS_BITS));

    c.unreset_block_wait(c.RESETS_RESET_BITS &
        ~(c.RESETS_RESET_ADC_BITS | c.RESETS_RESET_RTC_BITS | c.RESETS_RESET_SPI0_BITS |
        c.RESETS_RESET_SPI1_BITS | c.RESETS_RESET_UART0_BITS |
        c.RESETS_RESET_UART1_BITS | c.RESETS_RESET_USBCTRL_BITS));

    initialize_data();
}
