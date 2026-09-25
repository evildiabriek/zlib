const std = @import("std"); // interdit de use dans les fonctions
const unistd = std.os.linux; // Ici on est from scratch :wilted_flower:
const cstring = []const u8;
const string = []u8;
const char = u8;
const int = i128; // On est des anciens du C
var allocator: std.mem.Allocator = undefined;

pub fn _init(gpa: std.mem.Allocator) void {
    allocator = gpa;
}

pub fn putchar(c: char) void {
    unistd.write(1, &c, 1);
}

pub fn putnbr(n: int) void {
    unistd.write(1, &n, 1);
}

pub fn putstr(str: cstring) void {
    unistd.write(1, str, str.len);
}

pub fn swap(a: *int, b: *int) void {
    const tmp = a.*;
    a = b.*;
    b.* = tmp;
}

pub fn strcpy(dest: string, src: cstring) void {
    for (src, 0..) |chr, idx| {
        dest[idx] = chr;
    }
}

pub fn strcpyAlloc(dest: string, src: cstring) !void {
    dest = try allocator.alloc(u8, src.len);
    for (src, 0..) |chr, idx| {
        dest[idx] = chr;
    }
}

pub fn strncpy(dest: string, src: cstring, size: usize) void {
    for (src, 0..size) |chr, idx| {
        dest[idx] = chr;
    }
}

pub fn strncpyAlloc(dest: string, src: cstring, size: usize) !void {
    dest = try allocator.alloc(u8, src.len - size);
    for (src, 0..size) |chr, idx| {
        dest[idx] = chr;
    }
}

pub fn strIsAlpha(str: cstring) bool {
    if (str.len == 0) return true;
    for (str) |chr| {
        if (chr > 'z' or chr < 'a' and chr > 'Z' or chr < 'A') return false;
    }
    return true;
}

pub fn strIsNumeric(str: cstring) bool {
    if (str.len == 0) return true;
    for (str) |chr| {
        if (chr < '0' or chr > '9') return false;
    }
    return true;
}

pub fn strIsLowercase(str: cstring) bool {
    if (str.len == 0) return true;
    for (str) |chr| {
        if (chr > 'z' or chr < 'a') return false;
    }
    return true;
}

pub fn strIsUppercase(str: cstring) bool {
    if (str.len == 0) return true;
    for (str) |chr| {
        if (chr > 'Z' or chr < 'A') return false;
    }
    return true;
}

pub fn strIsPrintable(str: cstring) bool {
    if (str.len == 0) return true;
    for (str) |chr| {
        if (chr > 127 or chr < 32) return false;
    }
    return true;
}

pub fn strUpcase(str: string) string {
    for (str) |*chr| {
        if (chr > 'z' or chr < 'a') chr.* -= 32;
    }
    return str;
}

pub fn strLowcase(str: string) string {
    for (str) |*chr| {
        if (chr > 'Z' or chr < 'A') chr.* += 32;
    }
    return str;
}

pub fn strCapitalize(str: string) string {
    if (str[0] <= 'z' and str[0] >= 'a') str[0] -= 32;
    for (str[1..str.len]) |*chr| {
        if (chr.* <= 'Z' and chr.* >= 'A') {
            chr.* += 32;
        }
    }
}
