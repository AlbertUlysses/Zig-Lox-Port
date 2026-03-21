const std = @import("std");
const chunk = @import("chunk.zig");
const value = @import("value.zig");

fn simpleInstruction(name: []const u8, offset: u32) u32 {
    std.debug.print(" {s}\n", .{name});
    return offset + 1;
}
fn constantInstruction(name: []const u8, chunky: *chunk.Chunk, offset: u32) u32 {
    const constant = chunky.code[offset + 1];
    std.debug.print(" {s:} {d:0>4}\n", .{ name, constant });
    value.printValue(chunky.constants.values[constant]);
    std.debug.print("'\n", .{});
    return offset + 2;
}
fn disassembleInstruction(chunky: *chunk.Chunk, offset: u32) u32 {
    std.debug.print("{d:0>4}", .{offset});
    const instruction: chunk.OpCode = @enumFromInt(chunky.code[offset]);
    switch (instruction) {
        .OP_CONSTANT => {
            return constantInstruction("OP_CONSTANT", chunky, offset);
        },
        .OP_RETURN => {
            return simpleInstruction("OP_RETURN", offset);
        },
        // else => {
        //     std.debug.print("Unkown OpCode {}\n", .{instruction});
        //     return offset + 1;
        // },
    }
    return offset + 1;
}
pub fn disassembleChunk(chunky: *chunk.Chunk, name: []const u8) void {
    std.debug.print("== {s} ==\n", .{name});
    var offset: u32 = 0;
    while (offset < chunky.count) {
        offset = disassembleInstruction(chunky, offset);
    }
}
