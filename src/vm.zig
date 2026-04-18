const std = @import("std");
const chunk = @import("chunk.zig");
const value = @import("value.zig");
const debug = @import("lox_debug.zig");

pub const InterpretResult = enum(u8) {
    INTERPRET_OK,
    INTERPRET_COMPILE_ERROR,
    INTERPRET_RUNTIME_ERROR,
};

pub const VM = struct {
    chunk: *chunk.Chunk,
    ip: []u8,
    stack: []value.Value,
    stackTop: u32, //using numerics to point to the top of an array not sure if it's the best way to do it

    pub fn init(chunky: *chunk.Chunk, stack_max: u32) VM {
        return .{ .chunk = chunky, .ip = chunky.code, .stack = [stack_max]value.Value, .stackTop = 0 };
    }
    pub fn deinit(self: *VM) void {
        _ = self.chunk;
    }
    fn run(self: *VM) InterpretResult {
        var offset: u32 = 0;
        while (true) {
            debug.disassembleChunk(self.chunk, self.ip - self.chunk.code);
            const instruction: chunk.OpCode = @enumFromInt(self.ip[offset]);
            switch (instruction) {
                .OP_CONSTANT => {
                    value.printValue(self.chunk.constants.values[self.ip[offset]]);
                    std.debug.print("\n", .{});
                    break;
                },
                .OP_RETURN => {
                    return .INTERPRET_OK;
                },
                else => .INTERPET_COMPILE_ERROR,
            }
            offset += 1;
        }
    }
    pub fn interpret(self: *VM) InterpretResult {
        return self.run();
    }
};
