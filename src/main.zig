const std = @import("std");
const zlib = @import("Zlib");
const Io = std.Io;

//const Zlib = @import("Zlib");

pub fn main(init: std.process.Init) !void {
    try zlib.init(init.gpa, init.io, init.environ_map);
}
