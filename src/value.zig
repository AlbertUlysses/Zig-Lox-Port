const std = @import("std");

pub const Value = f64;

pub fn printValue(value: Value) void {
    std.debug.print("{e}", .{value});
}
pub const ValueArray = struct {
    capacity: u8,
    count: u8,
    values: []Value,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, count: u8, capacity: u8) !ValueArray {
        return .{ .allocator = allocator, .count = count, .capacity = capacity, .values = try allocator.alloc(Value, capacity) };
    }

    fn growCapacity(self: *ValueArray) void {
        if (self.capacity < 8) {
            self.capacity = 8;
        } else {
            self.capacity *= 2;
        }
    }
    fn growArray(self: *ValueArray) !void {
        self.values = try self.allocator.realloc(self.values, self.capacity);
    }

    pub fn writeValue(self: *ValueArray, value: Value) !void {
        if (self.capacity < self.count + 1) {
            std.debug.print("here\n", .{});
            self.growCapacity();
            try self.growArray();
        }
        self.values[self.count] = value;
        self.count += 1;
    }

    pub fn deinit(self: *ValueArray) void {
        const allocator = self.allocator;
        allocator.free(self.values);
    }
};
