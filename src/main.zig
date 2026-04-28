const std = @import("std");
const chunk = @import("chunk.zig");
const Zig_Lox_Port = @import("Zig_Lox_Port");
const lox_debug = @import("lox_debug.zig");
const vm = @import("vm.zig");
const STACK_MAX: u32 = 256;

// pick up here
fn repl() void {
    var line: = [1024]u8;
    while(true){
        std.debug.print("> ", .{});

        if(){
            std.debug.print("\n", .{});
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
