const std = @import("std");
const builtin = @import("builtin");

pub const targetOptions = std.Target.Query{
    .cpu_arch = .thumb,
    .os_tag = .freestanding,
    .abi = .eabi,
    .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m0plus },
    .cpu_features_add = std.Target.arm.featureSet(&[_]std.Target.arm.Feature{
        .soft_float,
    }),
};

pub fn build(b: *std.Build) !void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.resolveTargetQuery(targetOptions);

    const hal = b.addModule("hal", .{
        .root_source_file = b.path("rp2040.zig"),
        .target = target,
    });

    const arm_gcc_exe = b.findProgram(&.{"arm-none-eabi-gcc"}, &.{}) catch {
        std.log.err("Can't find arm-none-eabi-gcc in system path", .{});
        unreachable;
    };
    const gcc_arm_sysroot_path = std.mem.trim(u8, b.run(&.{ arm_gcc_exe, "-print-sysroot" }), "\r\n");
    const gcc_arm_multidir_relative_path = std.mem.trim(u8, b.run(&.{ arm_gcc_exe, "-mcpu=cortex-m0plus", "-mfloat-abi=soft", "-print-multi-directory" }), "\r\n");
    const gcc_arm_version = std.mem.trim(u8, b.run(&.{ arm_gcc_exe, "-dumpversion" }), "\r\n");
    const gcc_arm_lib_path1 = b.fmt("{s}/../lib/gcc/arm-none-eabi/{s}/{s}", .{ gcc_arm_sysroot_path, gcc_arm_version, gcc_arm_multidir_relative_path });
    const gcc_arm_lib_path2 = b.fmt("{s}/lib/{s}", .{ gcc_arm_sysroot_path, gcc_arm_multidir_relative_path });

    hal.addLibraryPath(.{ .cwd_relative = gcc_arm_lib_path1 });
    hal.addLibraryPath(.{ .cwd_relative = gcc_arm_lib_path2 });
    hal.addSystemIncludePath(.{ .cwd_relative = b.fmt("{s}/include", .{gcc_arm_sysroot_path}) });
    hal.linkSystemLibrary("gcc", .{});
    hal.addObjectFile(.{ .cwd_relative = b.fmt("{s}/libgcc.a", .{gcc_arm_lib_path1}) });
    hal.linkSystemLibrary("c_nano", .{});
    hal.linkSystemLibrary("m", .{});

    hal.addIncludePath(b.path("../pico-sdk/src/rp2_common/hardware_base/include"));
    hal.addIncludePath(b.path("../pico-sdk/src/rp2040/hardware_structs/include"));
    hal.addIncludePath(b.path("../pico-sdk/src/common/pico_base_headers/include"));
    hal.addIncludePath(b.path("../pico-sdk/src/rp2_common/hardware_uart/include"));
    hal.addIncludePath(b.path("../pico-sdk/src/rp2040/hardware_regs/include"));
    hal.addIncludePath(b.path("../pico-sdk/src/rp2040/pico_platform/include"));
    hal.addIncludePath(b.path("../pico-sdk/src/rp2_common/pico_platform_compiler/include"));
    hal.addIncludePath(b.path("../pico-sdk/src/rp2_common/pico_platform_sections/include"));
    hal.addIncludePath(b.path("../pico-sdk/src/rp2_common/pico_platform_panic/include"));
    hal.addIncludePath(b.path("../pico-sdk/src/rp2_common/hardware_resets/include"));
    hal.addIncludePath(b.path("../pico-sdk/src/rp2_common/hardware_clocks/include"));
    hal.addIncludePath(b.path("../pico-sdk/src/rp2_common/hardware_timer/include"));
    hal.addIncludePath(b.path("../pico-sdk/src/rp2_common/hardware_pll/include"));
    hal.addIncludePath(b.path("../pico-sdk/src/rp2_common/hardware_irq/include"));
    hal.addIncludePath(b.path("../pico-sdk/src/rp2_common/hardware_gpio/include"));
    hal.addIncludePath(b.path("../pico-sdk/src/rp2_common/hardware_sync/include"));
    hal.addIncludePath(b.path("../pico-sdk/src/rp2_common/hardware_sync_spin_lock/include"));
    hal.addIncludePath(b.path("../pico-sdk/src/common/hardware_claim/include"));
    hal.addIncludePath(b.path("../pico-sdk/src/common/pico_sync/include"));
    hal.addIncludePath(b.path("../pico-sdk/src/common/pico_time/include"));
    hal.addIncludePath(b.path("../pico-sdk/src/rp2_common/pico_runtime/include"));
    hal.addIncludePath(b.path("../pico-sdk/src/rp2_common/pico_runtime_init/include"));
    hal.addIncludePath(b.path("../pico-sdk/src/rp2_common/pico_divider/include"));
    hal.addIncludePath(b.path("../pico-sdk/src/rp2_common/hardware_divider/include"));

    hal.addCMacro("PICO_RP2040", "1");
    hal.addCMacro("PICO_DIVIDER_CALL_IDIV0", "0");
    hal.addCMacro("PICO_DIVIDER_CALL_LDIV0", "0");

    hal.addIncludePath(b.path("pico_generated/pico_base"));

    hal.addCSourceFiles(.{
        .files = &.{
            "../pico-sdk/src/rp2_common/hardware_uart/uart.c",
            "../pico-sdk/src/rp2_common/hardware_clocks/clocks.c",
            "../pico-sdk/src/rp2_common/hardware_irq/irq.c",
            "../pico-sdk/src/rp2_common/hardware_pll/pll.c",
            "../pico-sdk/src/rp2_common/hardware_gpio/gpio.c",
            "../pico-sdk/src/common/hardware_claim/claim.c",
            "../pico-sdk/src/rp2_common/hardware_timer/timer.c",
            "stubs.c",
        },
        .flags = &.{"-std=c23"},
    });
    hal.addAssemblyFile(b.path("../pico-sdk/src/rp2_common/hardware_irq/irq_handler_chain.S"));
    hal.addAssemblyFile(b.path("../pico-sdk/src/rp2_common/pico_divider/divider_hardware.S"));
    hal.addAssemblyFile(b.path("vector_table.S"));

    const systemStubs = b.addStaticLibrary(.{
        .name = "hal",
        .root_source_file = b.path("system_stubs.zig"),
        .target = target,
        .optimize = optimize,
    });

    hal.linkLibrary(systemStubs);
    systemStubs.addSystemIncludePath(.{ .cwd_relative = b.fmt("{s}/include", .{gcc_arm_sysroot_path}) });
}
