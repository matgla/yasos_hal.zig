const std = @import("std");
const hal = @import("yasos_hal");
const Builder = hal.Builder;

pub fn build(b: *std.Build) !void {
    const optimize = b.standardOptimizeOption(.{});
    const board = b.option([]const u8, "board", "a board for which the HAL is used") orelse "host";

    const boardDep = b.dependency("yasos_hal", .{
        .board = board,
        .root_file = @as([]const u8, b.pathFromRoot("hello_uart.zig")), //@as([]const u8, "hello_uart.zig"),
        .optimize = optimize,
        .name = @as([]const u8, "hello_uart_from_hal"),
    });
    b.installArtifact(boardDep.artifact("hello_uart_from_hal"));
    _ = boardDep.module("board");

    // if (yasosHal.resolved_target) |target| {
    //     const exe = b.addExecutable(.{
    //         .name = "hello_uart",
    //         .root_source_file = b.path("hello_uart.zig"),
    //         .target = target,
    //         .optimize = optimize,
    //     });
    //     exe.bundle_compiler_rt = false;
    //     yasosHal
    //         .exe.setLinkerScript(b.path("../../source/cortex-m0/raspberry/rp2040/linker_script.ld"));
    //     exe.root_module.addImport("board", yasosHal);
    //     exe.entry = .{ .symbol_name = "_reset_handler" };
    //     // see how exe is now referred as artifact
    //     b.installArtifact(exe);
    // }
}
