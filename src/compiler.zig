const std = @import("std");
const scanner = @import("scanner.zig");
const Chunk = @import("chunk.zig").Chunk;
const OpCode = @import("chunk.zig").OpCode;
const Value = @import("value.zig").Value;
const TokenType = @import("scanner").TokenType;

const Precedence = enum {
    PREC_NONE,
    PREC_ASSIGNMENT, // =
    PREC_OR, // or
    PREC_AND, // and
    PREC_EQUALITY, // == !=
    PREC_COMPARISON, // < > <= >=
    PREC_TERM, // + -
    PREC_FACTOR, // * /
    PREC_UNARY, // ! -
    PREC_CALL, // . ()
    PREC_PRIMARY,
    // can add precedence code here
    // pub fn precedenceFunction(self: Precedence) usize {
    //      here it should do work on the self like check what it is
    //      for example
    //      return @intFromEnum(self);
    //      this returns the usize of the Precedence class
    // };
};

const ParseRule = struct{
    // parsefn are functions - these are probably better as methods or sometype of ducktyping that can be determined at runtime
    prefix: Parsefn, 
    infix: Parsefn,
    precedence: Precdence,
};

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
pub fn emitReturn() void {
    emitByte(OpCode.OP_RETURN);
}

pub fn emitBytes(byte1: u8, byte2: u8) void {
    emitByte(byte1);
    emitByte(byte2);
}
pub fn makeConstant(value: Value, current_chunk: *Chunk) u8 {
    const constant = current_chunk.addConstant(value);
    if (constant > std.math.maxInt(u8)) {
        // below probably needs refactoring to actually work
        scanner.Scanner.errorToken("Too many constants in one chunk.");
        return 0;
    }
    return constant;
}
pub fn emitConstant(value: Value) void {
    emitBytes(OpCode.OP_CONSTANT, makeConstant(value));
}
//pick up above
// above needs grouping
pub fn endCompiler() void {
    emitReturn();
}
// below may need to be part of the parser or may need to reference it since it's not changing anything
pub fn binary(parser: *Parser) void {
    const operatorType = parser.previos.type;
    rule = getRule(operatorType);
    parsePrecedence(rule.precedence+1);
    switch(operatorType){
        .TOKEN_PLUS => emitByte(OPCode.OP_ADD),
        .TOKEN_MINUS => emitByte(OPCode.OP_MINUS),
        .TOKEN_STAR => emitByte(OPCode.OP_MULTIPLY),
        .TOKEN_SLASH => emitByte(OPCode.OP_DIVIDE),
        else => unreachable,
    }
}
pub fn grouping(parser: *Parser) void {
    expression();
    parser.consume(TokenType.TOKEN_RIGHT_PAREN, "Expect ')' after expression.");
}
pub fn number(parser: *Parser) void {
    const value: f64 = std.fmt.parseFloat(f64, parser.previous.start);
    emitConstant(value);
}
pub fn unary(parser: *Parser) void {
    const operatorType: TokenType = parser.previous.type;
    expression();
    switch (operatorType) {
        .TOKEN_MINUS => emitByte(OpCode.OP_NEGATE),
        else => {
            unreachable;
        },
    }
}

// below is used as a designated initializer syntax in c but essentially we will map the
// index to the enum I'll add the enum number hashed out next to it to remind me on what I have done
// this could cause issues down the line when the enums list gets either larger or moved around but for this iteration it should be suffient
const rules = {
    [_]ParseRule{
        {grouping, NULL,   PREC_NONE},//  [TOKEN_LEFT_PAREN]   
        {NULL,     NULL,   PREC_NONE},//  [TOKEN_RIGHT_PAREN]  
        {NULL,     NULL,   PREC_NONE},//  [TOKEN_LEFT_BRACE]   
        {NULL,     NULL,   PREC_NONE},//  [TOKEN_RIGHT_BRACE]  
        {NULL,     NULL,   PREC_NONE},//  [TOKEN_COMMA]        
        {NULL,     NULL,   PREC_NONE},//  [TOKEN_DOT]          
        {unary,    binary, PREC_TERM},//  [TOKEN_MINUS]        
        {NULL,     binary, PREC_TERM},//  [TOKEN_PLUS]         
        {NULL,     NULL,   PREC_NONE},//  [TOKEN_SEMICOLON]    
        {NULL,     binary, PREC_FACTOR},//  [TOKEN_SLASH]        
        {NULL,     binary, PREC_FACTOR},//  [TOKEN_STAR]         
        {NULL,     NULL,   PREC_NONE},//  [TOKEN_BANG]         
        {NULL,     NULL,   PREC_NONE},//  [TOKEN_BANG_EQUAL]   
        {NULL,     NULL,   PREC_NONE},//  [TOKEN_EQUAL]        
        {NULL,     NULL,   PREC_NONE},//  [TOKEN_EQUAL_EQUAL]  
        {NULL,     NULL,   PREC_NONE},//  [TOKEN_GREATER]      
        {NULL,     NULL,   PREC_NONE},//  [TOKEN_GREATER_EQUAL]
        {NULL,     NULL,   PREC_NONE},//  [TOKEN_LESS]         
        {NULL,     NULL,   PREC_NONE},//  [TOKEN_LESS_EQUAL]   
        {NULL,     NULL,   PREC_NONE},//  [TOKEN_IDENTIFIER]   
        {NULL,     NULL,   PREC_NONE},//  [TOKEN_STRING]       
        {number,   NULL,   PREC_NONE},//  [TOKEN_NUMBER]       
        {NULL,     NULL,   PREC_NONE},//  [TOKEN_AND]          
        {NULL,     NULL,   PREC_NONE},//  [TOKEN_CLASS]        
        {NULL,     NULL,   PREC_NONE},//  [TOKEN_ELSE]         
        {NULL,     NULL,   PREC_NONE},//  [TOKEN_FALSE]        
        {NULL,     NULL,   PREC_NONE},//  [TOKEN_FOR]          
        {NULL,     NULL,   PREC_NONE},//  [TOKEN_FUN]          
        {NULL,     NULL,   PREC_NONE},//  [TOKEN_IF]           
        {NULL,     NULL,   PREC_NONE},//  [TOKEN_NIL]          
        {NULL,     NULL,   PREC_NONE},//  [TOKEN_OR]           
        {NULL,     NULL,   PREC_NONE},//  [TOKEN_PRINT]        
        {NULL,     NULL,   PREC_NONE},//  [TOKEN_RETURN]       
        {NULL,     NULL,   PREC_NONE},//  [TOKEN_SUPER]        
        {NULL,     NULL,   PREC_NONE},//  [TOKEN_THIS]         
        {NULL,     NULL,   PREC_NONE},//  [TOKEN_TRUE]         
        {NULL,     NULL,   PREC_NONE},//  [TOKEN_VAR]          
        {NULL,     NULL,   PREC_NONE},//  [TOKEN_WHILE]        
        {NULL,     NULL,   PREC_NONE},//  [TOKEN_ERROR]        
        {NULL,     NULL,   PREC_NONE},//  [TOKEN_EOF]          
};
};
// above this should be with the parser class

// below it should perhaps be part of a difference class like precedence or maybe added to parser
pub fn parsePrecedence(precedence: Precedence) void {
    // throw away below -- it's just a place holder
    _ = precedence;
}
pub fn expression() void {
    parsePrecedence(Precedence.PREC_ASSIGNMENT);
}

pub fn compile(source: []const u8, chunk: *Chunk) bool {
    scanner = scanner.Scanner(source).init();
    // parser code is only defined and used here
    const parser = Parser.init(scanner);
    const compilingChunk: *Chunk = chunk;
    // place holder for now
    _ = compilingChunk;
    parser.advance();
    parser.expression();
    parser.consume(.TOKEN_EOF, "Expect end of Expression.");
    endCompiler();
    return !parser.hadError;
}
