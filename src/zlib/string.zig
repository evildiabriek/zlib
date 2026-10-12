const std = @import("std");

pub const StringError = error{
    IndexTooFar,
    ChrDoesntExist,
};

pub fn splitFree(gpa: std.mem.Allocator, arr: [][]const u8) void {
    for (arr) |str| {
        gpa.free(str);
    }
    gpa.free(arr);
}

pub const string = struct {
    value: []u8,

    allocator: std.mem.Allocator,
    //io: std.Io,

    pub fn init(gpa: std.mem.Allocator, str: []const u8) !@This() {
        return .{
            .value = try gpa.dupe(u8, str),
            .allocator = gpa,
        };
    }

    pub fn rewriteAlloc(self: *@This(), str: []const u8) !void {
        self.allocator.free(self.value);
        self.value = try self.allocator.dupe(u8, str);
    }

    // If the last rewrite is rewrite() and its not a allocated string, deinit will crash. I CAN put a check at deinit, but i wont
    pub fn rewrite(self: *@This(), str: []u8) void {
        self.allocator.free(self.value);
        self.value = str;
    }

    pub fn getAlloc(self: *@This()) ![]u8 {
        return try self.allocator.dupe(u8, self.value);
    }

    pub fn get(self: *@This()) []const u8 {
        return self.value;
    }

    pub fn length(self: *@This()) usize {
        return self.value.len;
    }

    pub fn cat(self: *@This(), str: []const u8) !void {
        const len = self.value.len;
        try self.resize(len + str.len);
        for (len..self.value.len, 0..) |idxval, idxstr| {
            self.value[idxval] = str[idxstr];
        }
    }

    pub fn getChr(self: *@This(), idx: usize) u8 {
        return self.value[idx];
    }

    pub fn compare(self: *@This(), str: []const u8) bool {
        return std.mem.eql(u8, self.value, str);
    }

    pub fn find(self: *@This(), str: []const u8) ?usize {
        return std.mem.find(u8, self.value, str);
    }

    pub fn findChr(self: *@This(), chr: u8) ?usize {
        return std.mem.findScalar(u8, self.value, chr);
    }

    pub fn findLast(self: *@This(), str: []const u8) ?usize {
        return std.mem.findLast(u8, self.value, str);
    }

    pub fn findChrLast(self: *@This(), chr: u8) ?usize {
        return std.mem.findScalarLast(u8, self.value, chr);
    }

    pub fn split(self: *@This(), str: []const u8) ![][]const u8 {
        var array: [][]const u8 = try self.allocator.alloc([]const u8, str.len + 1);
        var array_idx: usize = 0;
        var last_idx: usize = 0;
        for (self.value, 0..self.value.len) |chr, idx| {
            if (std.mem.findScalar(u8, str, chr) != null) {
                array[array_idx] = try self.allocator.dupe(u8, self.value[last_idx..idx]);
                array_idx += 1;
                last_idx = idx + 1;
            }
        }
        array[array_idx] = try self.allocator.dupe(u8, self.value[last_idx..]);
        array_idx += 1;
        return array[0..array_idx];
    }

    pub fn removeIndex(self: *@This(), idx: usize) !void {
        if (idx > self.value.len) return StringError.IndexTooFar;
        var buff: []u8 = try self.allocator.alloc(u8, self.value.len - 1);
        var index: usize = 0;
        var neg: usize = 0;
        for (self.value) |chr| {
            if (index == idx) {
                neg = 1;
                index += 1;
                continue;
            }
            buff[index - neg] = chr;
            index += 1;
        }
        self.rewrite(buff);
    }

    pub fn removeChr(self: *@This(), chr: u8) !void {
        if (self.findChr(chr) == null) return StringError.ChrDoesntExist;
        try self.removeIndex(self.findChr(chr).?);
    }

    pub fn replace(self: *@This(), bef: []const u8, aft: []const u8) !void {
        const buff: []u8 = try self.allocator.alloc(u8, std.mem.replacementSize(u8, self.value, bef, aft));
        _ = std.mem.replace(u8, self.value, bef, aft, buff);
        self.rewrite(buff);
    }

    pub fn startsWith(self: *@This(), str: []const u8) bool {
        return std.mem.startsWith(u8, self.value, str);
    }

    pub fn endswith(self: *@This(), str: []const u8) bool {
        return std.mem.endsWith(u8, self.value, str);
    }

    pub fn lstrip(self: *@This()) !void {
        var idx: usize = 0;
        while (std.ascii.isWhitespace(self.value[idx])) idx += 1;
        self.rewrite(try self.allocator.dupe(u8, self.value[idx..]));
    }

    pub fn rstrip(self: *@This()) !void {
        var idx: usize = self.value.len - 1;
        while (std.ascii.isWhitespace(self.value[idx])) idx -= 1;
        self.rewrite(try self.allocator.dupe(u8, self.value[0 .. idx + 1]));
    }

    pub fn resize(self: *@This(), size: usize) !void {
        self.value = try self.allocator.realloc(self.value, size);
    }

    pub fn strip(self: *@This()) !void {
        try self.lstrip();
        try self.rstrip();
    }

    pub fn lower(self: *@This()) void {
        for (self.value) |*chr| {
            if (std.ascii.isUpper(chr.*)) chr.* += 32;
        }
    }

    pub fn upper(self: *@This()) void {
        for (self.value) |*chr| {
            if (std.ascii.isLower(chr.*)) chr.* -= 32;
        }
    }

    pub fn count(self: *@This(), str: []const u8) usize {
        return std.mem.count(u8, self.value, str);
    }

    pub fn encode(self: *@This()) !void {
        var encoder = std.base64.Base64Encoder{ .alphabet_chars = std.base64.standard_alphabet_chars, .pad_char = '=' };
        const buff = try self.getAlloc();
        defer self.allocator.free(buff);
        try self.resize(encoder.calcSize(self.value.len));
        _ = encoder.encode(self.value, buff);
    }

    pub fn decode(self: *@This()) !void {
        var decoder = std.base64.Base64Decoder.init(std.base64.standard_alphabet_chars, '=');
        const buff = try self.getAlloc();
        defer self.allocator.free(buff);
        try self.resize(try decoder.calcSizeForSlice(buff));
        _ = try decoder.decode(self.value, buff);
    }

    pub fn slicing(self: *@This(), start: ?usize, end: ?usize) []u8 {
        return self.value[start orelse 0 .. end orelse self.value.len - 1];
    }

    pub fn deinit(self: *@This()) void {
        self.allocator.free(self.value);
    }
};
