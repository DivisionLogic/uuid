const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const bench = b.option(bool, "benchmark", "Run benchmarks?") orelse false;
    const options = b.addOptions();
    options.addOption(bool, "benchmark", bench);

    const benchmark = b.lazyDependency("benchmark", .{
        .target = target,
        .optimize = optimize,
    });
    _ = b.addModule("uuid", .{
        .root_source_file = b.path("src/root.zig"),
    });

    // Lib
    const lib = b.addStaticLibrary(.{
        .name = "uuid",
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(lib);

    // Unit Testing
    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    if (bench) {
        if (benchmark) |benchmark_dep| {
            lib_unit_tests.root_module.addImport("benchmark", benchmark_dep.module("benchmark"));
        }
    }
    lib_unit_tests.root_module.addOptions("opts", options);
    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}
