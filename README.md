[![CI](https://github.com/allyourcodebase/libchdr/actions/workflows/ci.yaml/badge.svg)](https://github.com/allyourcodebase/libchdr/actions)

# libchdr

This is [libchdr](https://github.com/rtissera/libchdr), packaged for [Zig](https://ziglang.org/).

## Installation

First, update your `build.zig.zon`:

```
# Initialize a `zig build` project if you haven't already
zig init
zig fetch --save git+https://github.com/allyourcodebase/libchdr.git
```

You can then import `libchdr` in your `build.zig` with:

```zig
const bzip_dependency = b.dependency("libchdr", .{
    .target = target,
    .optimize = optimize,
});
your_exe.linkLibrary(bzip_dependency.artifact("chdr"));
```

