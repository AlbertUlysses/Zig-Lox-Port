const std = @import("std");
const chunk = @import("chunk.zig");
const value = @import("value.zig");

fn simpleInstruction(name: []const u8, offset: u32) u32 {
    std.debug.print(" {s}\n", .{name});
    return offset + 1;
}
fn constantInstruction(name: []const u8, chunky: *chunk.Chunk, offset: u32) u32 {
    const constant = chunky.code[offset + 1];
    std.debug.print(" {s:<16} {d:>4} '", .{ name, constant });
    value.printValue(chunky.constants.values[constant]);
    std.debug.print("'\n", .{});
    return offset + 2;
}
fn disassembleInstruction(chunky: *chunk.Chunk, offset: u32) u32 {
    std.debug.print("{d:0>4}", .{offset});
    if ((offset > 0) and (chunky.lines[offset] == chunky.lines[offset - 1])) {
        std.debug.print("    | ", .{});
    } else {
        std.debug.print("{d:>4} ", .{chunky.lines[offset]});
    }
    const instruction: chunk.OpCode = @enumFromInt(chunky.code[offset]);
    switch (instruction) {
        .OP_CONSTANT => {
            return constantInstruction("OP_CONSTANT", chunky, offset);
        },
        .OP_RETURN => {
            return simpleInstruction("OP_RETURN", offset);
        },
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
