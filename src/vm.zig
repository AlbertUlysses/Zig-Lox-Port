const std = @import("std");
const chunk = @import("chunk.zig");
const value = @import("value.zig");
const debug = @import("lox_debug.zig");
const compiler = @import("compiler.zig");

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
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, chunky: *chunk.Chunk, stack_max: u32) !VM {
        //reset belongs here from section 15.2.1 - I instead left the init to set the stacktop to zero - but if this init is used outside of initializing we maybe need to set it to something else or figure out how to use reset elsewhere
        // need to allocate there
        return .{ .chunk = chunky, .ip = chunky.code, .stack = try allocator.alloc(value.Value, stack_max), .stackTop = 0, .allocator = allocator };
    }
    pub fn deinit(self: *VM) void {
        const allocator = self.allocator;
        allocator.free(self.stack);
    }
    fn run(self: *VM) InterpretResult {
        var offset: u32 = 0;
        while (true) {
            //should have a debug flag to execute below code
            // _ = debug.disassembleInstruction(self.chunk, offset);
            // std.debug.print("           ", .{});
            // for (0..self.stackTop) |slot| {
            //     std.debug.print("[ ", .{});
            //     value.printValue(self.stack[slot]);
            //     std.debug.print("] ", .{});
            // }
            // std.debug.print("\n", .{});
            // should have a debug flag to execute above code
            const instruction: chunk.OpCode = @enumFromInt(self.ip[offset]);
            switch (instruction) {
                .OP_CONSTANT => {
                    std.debug.print("constant\n", .{});
                    const constant = self.chunk.constants.values[self.ip[offset]];
                    std.debug.print("constant {d}\n", .{constant});
                    self.push(constant);
                    offset += 2;
                },
                // could refactor to simplify the code below
                .OP_ADD => {
                    std.debug.print("add\n", .{});
                    const b = self.pop();
                    const a = self.pop();
                    self.push(a + b);
                    offset += 1;
                },
                .OP_SUBTRACT => {
                    std.debug.print("sub\n", .{});
                    const b = self.pop();
                    const a = self.pop();
                    self.push(a - b);
                    offset += 1;
                },
                .OP_MULTIPLY => {
                    std.debug.print("multi\n", .{});
                    const b = self.pop();
                    const a = self.pop();
                    self.push(a * b);
                    offset += 1;
                },
                .OP_DIVIDE => {
                    std.debug.print("divide\n", .{});
                    const b = self.pop();
                    const a = self.pop();
                    self.push(a / b);
                    offset += 1;
                },
                // could refactor to simplify the code above
                .OP_NEGATE => {
                    std.debug.print("negate\n", .{});
                    self.push(-1 * self.pop());
                    offset += 1;
                },
                .OP_RETURN => {
                    value.printValue(self.pop());
                    std.debug.print("\n", .{});
                    return .INTERPRET_OK;
                },
                //else => .INTERPET_COMPILE_ERROR,
            }
        }
    }
    pub fn interpret(self: *VM, source: []const u8) InterpretResult {
        if (!self.compiler.compile(source)) {
            return .INTERPRET_COMPILER_ERROR;
        }
        self.ip = self.chunk.code;
        const result: InterpretResult = self.run();
        return result;
    }
    fn push(self: *VM, valuey: value.Value) void {
        std.debug.print("push\n", .{});
        std.debug.print("stacktop {d}\n", .{self.stackTop});
        self.stack[self.stackTop] = valuey;
        self.stackTop += 1;
    }
    fn pop(self: *VM) value.Value {
        std.debug.print("pop\n", .{});
        std.debug.print("stacktop {d}\n", .{self.stackTop});
        self.stackTop -= 1;
        return self.stack[self.stackTop];
    }
};
