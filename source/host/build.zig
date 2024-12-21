const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) !void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    _ = b.addModule("hal", .{
        .root_source_file = b.path("host.zig"),
        .target = target,
        .optimize = optimize,
    });
}
