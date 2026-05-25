const std = @import("std");
const scanner = @import("scanner.zig");
const Chunk = @import("chunk.zig").Chunk;
const OpCode = @import("chunk.zig").OpCode;
const Value = @import("value.zig").Value;

const Parser = struct {
    scanner: *scanner.Scanner,
    current: ?scanner.Token,
    previous: ?scanner.Token,
    hadError: bool,
    panicMode: bool,
    // have the current and previous as null could cause issues but ideally it stays as
    // null only for iteration
    pub fn init(init_scanner: *scanner.Scanner) Parser {
        return .{ .scanner = init_scanner, .current = null, .previous = null, .hadError = false, .panicMode = false };
    }

    pub fn advance(self: *Parser) void {
        self.previous = self.current;
        while (true) {
            self.current = self.scanner.scanToken();
            if (self.current.token_type != scanner.TokenType.TOKEN_ERROR) break;
            self.errorAtCurrent(self.current.start);
        }
    }
    pub fn consume(self: *Parser, token_type: scanner.TokenType, message: []const u8) void {
        if (self.current.token_type == token_type) {
            self.advance();
            return {};
        }
        self.errorAtCurrent(message);
    }
    fn errorAtCurrent(self: *Parser, message: []const u8) void {
        self.errorAt(self.previous, message);
    }
    fn errorAt(self: *Parser, token: scanner.Token, message: []const u8) void {
        // this should be a standard error
        if (self.panicMode) return {};
        self.panicMode = true;
        std.debug.print("[line .{d}] Error", .{token.line});
        switch (token.token_type) {
            scanner.TokenType.TOKEN_EOF => std.debug.print("at end", .{}),
            scanner.TokenType.TOKEN_ERROR => {},
            else => {
                std.debug.print(" at '{d}.*{s}'", .{ token.start.len, token.start });
            },
        }
        std.debug.print(": {s}\n", .{message});
        self.hadError = true;
    }
};
// these should probably be moved somewhere else or used with something else.
// maybe we move the chunk to the parser?
// or we pass the line into the function..
// but these are related to chunk code they just don't have a place in this file ... yet
pub fn emitByte(chunk: *Chunk, byte: u8, parser: Parser) void {
    chunk.writeChunk(byte, parser.previous.line());
}
pub fn emitReturn(byte1: u8, byte2: u8) void {
    emitByte(byte1);
    emitByte(byte2);
}
pub fn makeConstant(value: Value) u8 {
    const constant = addConstant(currentChunk(), value);
    if (constant > std.math.maxInt(u8)){
        errorFn("Too many constants in one chunk.");
        return 0;
    }
    return constant;
}
pub fn emitConstant(value: Value) void {
    emitBytes(OpCode.OP_CONSTANT, makeConstant(value));
}
//pick up above
// above needs grouping
pub fn endCompiler()void{
    emitReturn();
}
pub fn number(parser: Parse)void{
    const value: f64 = std.fmt.parseFloat(f64, parse.previous.start);
    emitConstant(value);
}
pub fn expression()void{
}

pub fn compile(source: []const u8, chunk: *Chunk) bool {
    scanner = scanner.Scanner(source).init();
    // parser code is only defined and used here
    const parser = Parser.init(scanner);
    const compilingChunk: *Chunk = chunk;
    parser.advance();
    parser.expression();
    parser.consume(.TOKEN_EOF, "Expect end of Expression.");
    endCompiler();
    return !parser.hadError;
}
