const _ = @import("startup.zig");

const c = @cImport({
    @cInclude("sys/types.h");
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

export fn system_init() void {}
