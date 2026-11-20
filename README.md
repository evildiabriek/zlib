# Install

---

```bash
zig fetch --save git+https://github.com/evildiabriek/zlib
```

In the `build.zig`

```zig
const dep = b.dependency("zlib", .{
    .target = target,
    .optimize = optimize,
});
exe.root_module.addImport("zlib", dep.module("zlib"));
```

## PRECISION

---

Its NOT the zlib compression library. Its my own little library for Zig
