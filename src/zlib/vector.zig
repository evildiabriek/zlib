const std = @import("std");

const VecError = error{
    MaxIndexReached,
};

pub fn CreateVec(comptime T: type) type {
    return struct {
        items: []T,
        allocator: std.mem.Allocator,
        n_of_element: usize,
        pub fn init(Init: std.mem.Allocator) @This() {
            return .{ .allocator = Init, .n_of_element = 0, .items = &[_]T{} };
        }

        pub fn appendNoAlloc(self: *@This(), nv: T) !usize {
            self.n_of_element += 1;
            self.items = try self.allocator.realloc(self.items, self.n_of_element);
            self.items[self.n_of_element - 1] = nv;
            return self.n_of_element - 1;
        }

        pub fn append(self: *@This(), new_value: T) !usize {
            self.n_of_element += 1;
            self.items = try self.allocator.realloc(self.items, self.n_of_element);
            if (comptime @typeInfo(T) == .pointer and @typeInfo(T).pointer.size == .slice) {
                self.items[self.n_of_element - 1] = try self.allocator.dupe(std.meta.Elem(T), new_value);
            } else {
                self.items[self.n_of_element - 1] = new_value;
            }
            return self.n_of_element - 1;
        }

        pub fn getValue(self: *@This(), idx: usize) !T {
            if (idx > self.n_of_element - 1) return VecError.MaxIndexReached;
            return self.items[idx];
        }

        pub fn remove(self: *@This(), idx: usize) !void {
            if (idx > self.n_of_element - 1) return VecError.MaxIndexReached;
            const max_idx = self.n_of_element - 1;
            var m_idx = idx;
            while (m_idx < max_idx) {
                self.allocator.free(self.items[m_idx]);
                self.items[m_idx] = self.items[m_idx + 1];
                m_idx += 1;
            }
            self.n_of_element -= 1;
        }

        pub fn clear(self: *@This()) !void {
            while (0 < self.n_of_element) {
                try self.remove(self.n_of_element - 1);
                self.n_of_element -= 1;
            }
        }

        pub fn length(self: @This()) usize {
            return self.n_of_element;
        }

        pub fn getAllElementsDupe(self: @This()) ![]T {
            return try self.allocator.dupe(T, self.items);
        }

        pub fn resize(self: *@This(), size: usize) !void {
            if (self.n_of_element > size) {
                for (self.items[self.n_of_element..size]) |itm| {
                    self.allocator.free(itm);
                }
            }
            self.items = try self.allocator.realloc(self.items, size);
            self.n_of_element = size;
        }

        pub fn deinit(self: *@This()) void {
            if (comptime @typeInfo(T) == .pointer and @typeInfo(T).pointer.size == .slice) {
                while (0 < self.n_of_element) {
                    self.allocator.free(self.items[self.n_of_element - 1]);
                    self.n_of_element -= 1;
                }
            }
            self.allocator.free(self.items);
        }
    };
}
