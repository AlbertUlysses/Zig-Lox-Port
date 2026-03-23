const std = @import("std");
const chunk = @import("chunk.zig");

pub const InterpretResult = enum {
    INTERPRET_OK,
    INTERPRET_COMPILE_ERROR,
    INTERPRET_RUNTIME_ERROR,
};

pub const VM = struct {
    chunkies: *chunk.Chunk,
    ip: []u8,
    // allocator: std.mem.Allocator,

    // pub fn init(allocator: std.mem.Allocator, capacity: u8) VM {
    //     return .{
    //         .allocator = allocator,
    //         .chunkies = try allocator.alloc(chunk.Chunk, capacity),
    //     };
    // }
    // pub fn deinit(
    //     self: *VM,
    // ) void {
    //     const allocator = self.allocator;
    //     allocator.free(self.chunkies);
    // }
    pub fn interpret(self: VM, chunky: *chunk.Chunk) InterpretResult {
        self.chunkies = chunky;
        self.ip = self.chunkies.code;
        return self.run();
    }
};
