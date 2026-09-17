const std = @import("std");

// USE ZIG 0.16.0

pub fn build(b: *std.Build) void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .thumb,
        .os_tag = .freestanding,
        .abi = .eabi,
        .cpu_model = std.Target.Query.CpuModel{ .explicit = &std.Target.arm.cpu.cortex_m0plus },
    });
    const executable_name = "m0";

    const optimize = b.standardOptimizeOption(.{});

    const m0plus = b.addModule(executable_name, .{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = false,
        .sanitize_c = .off, // Excludes UBSAN code to prevent from bloating binary
        .single_threaded = true,
    });

    const m0plus_exe = b.addExecutable(.{
        .name = executable_name ++ ".elf",
        .root_module = m0plus,
        .linkage = .static,
    });

    m0plus_exe.setLinkerScript(b.path("linker/STM32G030F6P6.ld"));
    m0plus_exe.link_gc_sections = true;
    m0plus_exe.link_data_sections = true;
    m0plus_exe.link_function_sections = true;

    b.installArtifact(m0plus_exe);

    // Generate raw binary from ELF
    const bin = b.addObjCopy(m0plus_exe.getEmittedBin(), .{
        .format = .bin,
    });
    const install_bin = b.addInstallBinFile(
        bin.getOutput(),
        executable_name ++ ".bin",
    );
    b.getInstallStep().dependOn(&install_bin.step);

    // Flash firmware into target
    const flash_cmd = b.addSystemCommand(&.{
        "JLink",
        "-device",
        "STM32G030F6",
        "-if",
        "SWD",
        "-speed",
        "4000",
        "-CommandFile",
        "flash.jlink",
    });
    flash_cmd.step.dependOn(b.getInstallStep());

    const flash_step = b.step("flash", "Flash firmware via J-Link");
    flash_step.dependOn(&flash_cmd.step);
}
