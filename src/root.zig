pub const dictionnary = @import("zlib/dictionnary.zig");
pub const fs = @import("zlib/fs.zig");
pub const net = @import("zlib/net.zig");
pub const vector = @import("zlib/vector.zig");
pub const env = @import("zlib/env.zig");
pub const string = @import("zlib/string.zig");
const std = @import("std");
pub fn init(gpa: std.mem.Allocator, IO: std.Io, em: *std.process.Environ.Map) !void {
    fs._init(IO, gpa);
    try net._init(gpa, IO);
    env.init(gpa, em);
}

pub fn deinit() void {
    net._deinit();
}
