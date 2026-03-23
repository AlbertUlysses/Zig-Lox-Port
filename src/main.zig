const std = @import("std");
const chunk = @import("chunk.zig");
const Zig_Lox_Port = @import("Zig_Lox_Port");
const lox_debug = @import("lox_debug.zig");
const vm = @import("vm.zig");

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}).init;
    defer _ = gpa.deinit();
    const ally = gpa.allocator();

    var vm_instance = vm.VM;
    //defer vm_instance.deinit();
    var new_chunk = try chunk.Chunk.init(ally, 0, 4);
    defer new_chunk.deinit();
    const constant: u8 = try new_chunk.addConstant(1.2);
    try new_chunk.writeChunk(@intFromEnum(chunk.OpCode.OP_CONSTANT), 123);
    try new_chunk.writeChunk(constant, 123);
    try new_chunk.writeChunk(@intFromEnum(chunk.OpCode.OP_RETURN), 123);
    lox_debug.disassembleChunk(&new_chunk, "test chunk");
    vm_instance.interpret(&new_chunk);
}
