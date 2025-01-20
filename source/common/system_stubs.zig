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

extern var end: u8;
extern var __heap_limit__: u8;
var heap_end: *u8 = &end;

export fn _sbrk(incr: usize) *allowzero anyopaque {
    const prev_heap_end: *u8 = heap_end;
    const next_heap_end: *u8 = @ptrFromInt(@intFromPtr(heap_end) + incr);
    if (@intFromPtr(next_heap_end) >= @intFromPtr(&__heap_limit__)) {
        return @ptrFromInt(0);
    }
    heap_end = next_heap_end;
    return prev_heap_end;
}

export fn hard_assertion_failure() void {
    while (true) {}
}
