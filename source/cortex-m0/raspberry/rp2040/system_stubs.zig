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
    @cInclude("sys/types.h");
    @cInclude("sys/stat.h");
});

export fn _exit(_: c_int) void {
    while (true) {}
}

export fn _kill(_: c.pid_t, _: c_int) c.pid_t {
    return 0;
}

export fn _getpid() c.pid_t {
    return 0;
}

export fn __unhandled_user_irq() void {
    while (true) {}
}

export fn panic(_: *const c_char, ...) void {
    while (true) {}
}

export fn _fstat(_: c_int, _: *c.struct_stat) c_int {
    return 0;
}

export fn _isatty(_: c_int) c_int {
    return 0;
}

export fn _close(_: c_int) c_int {
    return 0;
}

export fn _lseek(_: c_int, _: c.off_t, _: c_int) c_int {
    return 0;
}

export fn _read(_: c_int, _: *void, _: usize) isize {
    return 0;
}

export fn _write(_: c_int, _: *const void, _: usize) isize {
    return 0;
}

export fn _open(_: *const c_char, _: c_int) c_int {
    return 0;
}

export fn _sbrk(_: isize) *void {
    var buf: [10]u8 = undefined;
    return @ptrCast(buf[0..10].ptr);
}

export fn system_init() void {}
