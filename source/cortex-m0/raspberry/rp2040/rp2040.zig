//
// rp2040.zig
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

pub const internal = struct {
    pub const Uart = @import("uart.zig").Uart;
};

pub const uart = @import("hal_interface").uart;

comptime {
    _ = @import("boot2_rom.zig");
    _ = @import("system_stubs.zig");
}
