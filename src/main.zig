const std = @import("std");
const chunk = @import("chunk.zig");
const Zig_Lox_Port = @import("Zig_Lox_Port");
const lox_debug = @import("lox_debug.zig");
const vm = @import("vm.zig");
const STACK_MAX: u32 = 256;

// pick up here
fn repl() void {
    var stdin_buffer: [1024]u8 = undefined; // line
    var stdout_buffer: [1024]u8 = undefined; // stdout 
    var stdin_reader = std.fs.File.stdin().writer(&stdin_buffer);
    var stdout_writer = std.fs.File.stdout().reader(&stdout_buffer);
    const stdin = &stdin_reader.interface;
    const stdout = &stdout_reader.interface;
    while(true){
        try stdout.print("> ");
        try stdout.flush();
        const line = try stdin.takeDelimiterExclusive('\n');
        if(std.mem.eql(u8, line, "exit()")){
            try stdout.writeAll("\n");
            try stdout.flush();
            break;
        }
        interpret(line);
    }
}
//pick upabove
pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}).init;
    defer _ = gpa.deinit();
    const ally = gpa.allocator();

    var new_chunk = try chunk.Chunk.init(ally, 0, 4);
    defer new_chunk.deinit();

    var vmy = try vm.VM.init(ally, &new_chunk, STACK_MAX);
    _ = vmy.interpret();

    if (std.os.argv.len == 1){
        repl();
    }else if (std.os.argv.len == 2){
        runFile(std.os.argv[1]);
    } else{
        std.debug.print("Usage: clox [path] \n", .{});
        std.process.exit(64);
    }
    defer vmy.deinit();
}
