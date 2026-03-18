const std = @import("std");

pub const OpCode = enum(u8) {
    OP_RETURN,
};

pub const Chunk = struct {
    count: u8,
    capacity: u8,
    code: []u8,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, count: u8, capacity: u8) !Chunk {
        return .{ .allocator = allocator, .count = count, .capacity = capacity, .code = try allocator.alloc(u8, capacity) };
    }
    fn growCapacity(self: *Chunk) void {
        if (self.capacity < 8) {
            self.capacity = 8;
        } else {
            self.capacity *= 2;
        }
    }
    fn growArray(self: *Chunk) !void {
        self.code = try self.allocator.realloc(self.code, self.capacity);
    }

    pub fn writeChunk(self: *Chunk, byte: u8) !void {
        // check if we maximized capacity if yes then grow the capacity
        std.debug.print("capacity: {}, count: {}\n", .{ self.capacity, self.count });
        if (self.capacity < self.count + 1) {
            std.debug.print("here\n", .{});
            self.growCapacity();
            try self.growArray();
        }
        self.code[self.count] = byte;
        self.count += 1;
    }

    pub fn deinit(self: *Chunk) void {
        const allocator = self.allocator;
        allocator.free(self.code);
    }
};
