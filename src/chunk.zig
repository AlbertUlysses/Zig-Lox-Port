const std = @import("std");
const value = @import("value.zig");

pub const OpCode = enum(u8) {
    OP_CONSTANT,
    OP_RETURN,
};

pub const Chunk = struct {
    count: u8,
    capacity: u8,
    code: []u8,
    lines: []u32,
    constants: value.ValueArray,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, count: u8, capacity: u8) !Chunk {
        return .{ .allocator = allocator, .count = count, .capacity = capacity, .code = try allocator.alloc(u8, capacity), .lines = try allocator.alloc(u32, capacity), .constants = try value.ValueArray.init(allocator, count, capacity) };
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
        self.lines = try self.allocator.realloc(self.lines, self.capacity);
    }

    pub fn writeChunk(self: *Chunk, byte: u8, line: u32) !void {
        if (self.capacity < self.count + 1) {
            self.growCapacity();
            try self.growArray();
            try self.growArray();
        }
        self.code[self.count] = byte;
        self.lines[self.count] = line;
        self.count += 1;
    }
    pub fn addConstant(self: *Chunk, chunk_value: value.Value) !u8 {
        try self.constants.writeValue(chunk_value);
        return self.constants.count - 1;
    }

    pub fn deinit(self: *Chunk) void {
        const allocator = self.allocator;
        allocator.free(self.code);
        allocator.free(self.lines);
        self.constants.deinit();
    }
};
