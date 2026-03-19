const std = @import("std");
//const common = @import("common");
const chunk = @import("chunk.zig");
const Zig_Lox_Port = @import("Zig_Lox_Port");
const lox_debug = @import("lox_debug.zig");

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}).init;
    defer _ = gpa.deinit();
    const ally = gpa.allocator();

    //const args = try std.process.argsAlloc(ally);
    //defer std.prcoess.argsFree(ally, args);
    var new_chunk = try chunk.Chunk.init(ally, 0, 4);
    defer new_chunk.deinit();
    try new_chunk.writeChunk(@intFromEnum(chunk.OpCode.OP_RETURN));
    lox_debug.disassembleChunk(&new_chunk, "test chunk");
    //std.debug.print("Bytes: {} \n", .{new_chunk.code[0]});
}
