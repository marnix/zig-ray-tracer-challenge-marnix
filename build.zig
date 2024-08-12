const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    {
        const unit_tests = b.addTest(.{
            .root_source_file = b.path("src/alltests.zig"),
            .target = target,
            .optimize = optimize,
        });
        const run_unit_tests = b.addRunArtifact(unit_tests);

        const test_step = b.step("test", "Run unit tests");
        test_step.dependOn(&run_unit_tests.step);
    }

    {
        const exe = b.addExecutable(.{
            .name = "chapter-01-cannon",
            .root_source_file = b.path("src/chapter-01-cannon.zig"),
            .target = target,
            .optimize = optimize,
        });
        b.installArtifact(exe);
        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(b.getInstallStep());
        const run_step = b.step("run-01-cannon", "Run the Chapter 1 'Putting It Together'");
        run_step.dependOn(&run_cmd.step);
    }

    {
        const exe = b.addExecutable(.{
            .name = "chapter-02-cannon",
            .root_source_file = b.path("src/chapter-02-cannon.zig"),
            .target = target,
            .optimize = optimize,
        });
        b.installArtifact(exe);
        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(b.getInstallStep());
        const run_step = b.step("run-02-cannon", "Run the Chapter 2 'Putting It Together'");
        run_step.dependOn(&run_cmd.step);
    }
}
