const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const upstream = b.dependency("upstream", .{});

    const zstd_dependency = b.dependency("zstd", .{
        .target = target,
        .optimize = optimize,
    });
    const zlib_dependency = b.dependency("zlib", .{
        .target = target,
        .optimize = optimize,
    });

    // use vendored lzma
    const lzma_lib = b.addStaticLibrary(.{
        .target = target,
        .optimize = optimize,
        .name = "lzma",
    });

    lzma_lib.addCSourceFiles(.{
        .root = upstream.path("deps/lzma-24.05/src"),
        .files = &.{
            "Alloc.c",
            "Bra.c",
            "Bra86.c",
            "BraIA64.c",
            "CpuArch.c",
            "Delta.c",
            "LzFind.c",
            "Lzma86Dec.c",
            "LzmaDec.c",
            "LzmaEnc.c",
            "Sort.c",
        },
        .flags = &.{
            "-DZ7_ST",
        },
    });
    lzma_lib.linkLibC();
    lzma_lib.addIncludePath(upstream.path("deps/lzma-24.05/include"));
    lzma_lib.installHeadersDirectory(upstream.path("deps/lzma-24.05/include"), "", .{});

    const lib = b.addStaticLibrary(.{
        .target = target,
        .optimize = optimize,
        .name = "chdr",
    });

    lib.addCSourceFiles(.{
        .root = upstream.path("src"),
        .files = &.{
            "libchdr_bitstream.c",
            "libchdr_cdrom.c",
            "libchdr_chd.c",
            "libchdr_flac.c",
            "libchdr_huffman.c",
        },
    });
    lib.linkLibC();

    lib.addIncludePath(upstream.path("include"));
    lib.installHeadersDirectory(upstream.path("include/libchdr"), "libchdr", .{});

    lib.linkLibrary(lzma_lib);
    if (b.systemIntegrationOption("zlib", .{})) {
        lib.linkSystemLibrary("zlib");
    } else {
        lib.linkLibrary(zlib_dependency.artifact("z"));
    }
    if (b.systemIntegrationOption("zstd", .{})) {
        lib.linkSystemLibrary("zstd");
    } else {
        lib.linkLibrary(zstd_dependency.artifact("zstd"));
    }

    b.installArtifact(lib);
}
