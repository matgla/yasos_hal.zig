//
// build.zig
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
const buildin = @import("builtin");

const BoardConfigData = struct {
    mcu: []const u8,
    linker_script: []const u8,
    bundle_compiler_rt: bool,
    entry: []const u8,
};

pub const BoardConfig = struct {
    data: BoardConfigData,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, data: BoardConfigData) !BoardConfig {
        return BoardConfig{ .data = BoardConfigData{
            .mcu = try allocator.dupe(u8, data.mcu),
            .linker_script = try allocator.dupe(u8, data.linker_script),
            .bundle_compiler_rt = data.bundle_compiler_rt,
            .entry = try allocator.dupe(u8, data.entry),
        }, .allocator = allocator };
    }

    pub fn deinit(self: BoardConfig) void {
        self.allocator.free(self.data.mcu);
        self.allocator.free(self.data.linker_script);
        self.allocator.free(self.data.entry);
    }
};

pub fn build(b: *std.Build) !void {
    // build system dependency
    const board = b.option([]const u8, "board", "a board for which the HAL is used") orelse "host";
    const execName = b.option([]const u8, "name", "application name for which HAL is used") orelse unreachable;
    const root_file = b.option([]const u8, "root_file", "application root file") orelse unreachable;
    const cmake = b.option([]const u8, "cmake", "path to CMake executable") orelse "";
    const gcc = b.option([]const u8, "gcc", "path to arm-none-eabi-gcc executable") orelse "";

    const optimize = b.standardOptimizeOption(.{});
    std.log.info("Used board - {s}", .{board});

    const builder = Builder{};
    try builder.configureBoard(b, @as([]const u8, board), @as([]const u8, execName), root_file, optimize, @as([]const u8, cmake), @as([]const u8, gcc));
}

pub const Builder = struct {
    pub fn configureBoard(_: *const Builder, b: *std.Build, board: []const u8, execName: []const u8, root_file: []const u8, optimize: std.builtin.OptimizeMode, cmake: []const u8, gcc: []const u8) !void {
        const boardDependency = try std.fmt.allocPrint(b.allocator, "boards/{s}/{s}.zig", .{ board, board });
        defer b.allocator.free(boardDependency);

        const boardConfig = try parseMcuConfigurationFile(b.allocator, b, board);
        defer boardConfig.deinit();

        const halDependency = try std.fmt.allocPrint(b.allocator, "{s}", .{boardConfig.data.mcu});
        defer b.allocator.free(halDependency);
        const mcu = b.dependency(halDependency, .{
            .cmake = cmake,
            .gcc = gcc,
        });
        const boardModule = b.addModule("board", .{
            .root_source_file = b.path(boardDependency),
        });
        boardModule.addImport("hal", mcu.module("hal"));
        const root_path = std.Build.LazyPath{ .src_path = .{ .sub_path = root_file, .owner = b } };

        if (mcu.module("hal").resolved_target) |target| {
            const exe = b.addExecutable(.{
                .name = execName,
                .root_source_file = root_path,
                .target = target,
                .optimize = optimize,
            });
            exe.want_lto = false;
            exe.root_module.addImport("board", boardModule);
            exe.root_module.addImport("hal", mcu.module("hal"));
            if (boardConfig.data.linker_script.len > 0) {
                const linkerScript = try std.fmt.allocPrint(b.allocator, "source/{s}", .{boardConfig.data.linker_script});
                defer b.allocator.free(linkerScript);

                exe.setLinkerScript(b.path(linkerScript));
            }

            exe.bundle_compiler_rt = boardConfig.data.bundle_compiler_rt;

            if (boardConfig.data.entry.len > 0) {
                exe.entry = .{ .symbol_name = b.dupe(boardConfig.data.entry) };
            }
            // see how exe is now referred as artifact
            b.installArtifact(exe);
        }
    }

    pub fn parseMcuConfigurationFile(allocator: std.mem.Allocator, b: *std.Build, board: []const u8) !BoardConfig {
        const configPath = try std.fmt.allocPrint(b.allocator, "boards/{s}/{s}.json", .{ board, board });
        defer b.allocator.free(configPath);

        std.log.info("Opening file: {s}", .{configPath});
        const file = try std.fs.cwd().openFile(b.pathFromRoot(configPath), .{});
        defer file.close();

        const data = try file.readToEndAlloc(b.allocator, 4096);
        defer b.allocator.free(data);
        const parsed = try std.json.parseFromSlice(
            BoardConfigData,
            allocator,
            data,
            .{},
        );
        defer parsed.deinit();
        return BoardConfig.init(allocator, parsed.value);
    }
};
