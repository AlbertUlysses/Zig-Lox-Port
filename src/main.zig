const std = @import("std");
const chunk = @import("chunk.zig");
const Zig_Lox_Port = @import("Zig_Lox_Port");
const lox_debug = @import("lox_debug.zig");
const vm = @import("vm.zig");
const STACK_MAX: u32 = 256;

fn repl(vmy: vm.VM) void {
    var stdin_buffer: [1024]u8 = undefined; // line
    var stdout_buffer: [1024]u8 = undefined; // stdout
    var stdin_reader = std.fs.File.stdin().writer(&stdin_buffer);
    var stdout_writer = std.fs.File.stdout().reader(&stdout_buffer);
    const stdin = &stdin_reader.interface;
    const stdout = &stdout_writer.interface;
    while (true) {
        try stdout.print("> ");
        try stdout.flush();
        const line = try stdin.takeDelimiterExclusive('\n');
        if (std.mem.eql(u8, line, "exit()")) {
            try stdout.writeAll("\n");
            try stdout.flush();
            break;
        }
        vmy.interpret(line);
    }
}

fn runFile(path: []u8, vmy: vm.VM, ally: std.mem.Allocator) void {
    const source = readFile(path, ally);
    const result = vmy.interpret(source);
    switch (result) {
        .INTERPRET_COMPILE_ERROR => {
            std.process.exit(65);
        },
        .INTERPRET_RUNTIME_ERROR => {
            std.process.exit(65);
        },
        else => {},
    }
}

fn readFile(path: []u8, ally: std.mem.Allocator) void {
    const cwd = std.fs.cwd();
    const max_bytes = 16 * 1024 * 1024; // reading in the whole text of the file
    const text = try cwd.readFileAlloc(ally, path, max_bytes);
    return text;
}
// pick after writing the readFile and now need to check if the text is empty
pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}).init;
    defer _ = gpa.deinit();
    const ally = gpa.allocator();

    var new_chunk = try chunk.Chunk.init(ally, 0, 4);
    defer new_chunk.deinit();

    var vmy = try vm.VM.init(ally, &new_chunk, STACK_MAX);
    _ = vmy.interpret();

    if (std.os.argv.len == 1) {
        repl(vmy);
    } else if (std.os.argv.len == 2) {
        runFile(std.os.argv[1], vmy, ally);
    } else {
        std.debug.print("Usage: clox [path] \n", .{});
        std.process.exit(64);
    }
    defer vmy.deinit();
}
