const std = @import("std");
const zstring = @import("zlib/string.zig");
const Io = std.Io;

//const Zlib = @import("Zlib");

pub fn main(init: std.process.Init) !void {
    var str: zstring.string = try .init(init.gpa, "abc,def");
    defer str.deinit();
    std.log.debug("{s}", .{str.get()});
    try str.encode();
    std.log.debug("{s}", .{str.get()});
    try str.decode();
    std.log.debug("{s}", .{str.get()});
    try str.cat("caditquoi");
    std.log.debug("{s}", .{str.get()});
}
