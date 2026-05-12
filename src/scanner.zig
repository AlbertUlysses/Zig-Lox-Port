const std = @import("std");
pub const TokenType = enum {
    TOKEN_LEFT_PAREN,
    TOKEN_RIGHT_PAREN,
    TOKEN_LEFT_BRACE,
    TOKEN_RIGHT_BRACE,
    TOKEN_COMMA,
    TOKEN_DOT,
    TOKEN_MINUS,
    TOKEN_PLUS,
    TOKEN_SEMICOLON,
    TOKEN_SLASH,
    TOKEN_STAR,
    // One or two character tokens.
    TOKEN_BANG,
    TOKEN_BANG_EQUAL,
    TOKEN_EQUAL,
    TOKEN_EQUAL_EQUAL,
    TOKEN_GREATER,
    TOKEN_GREATER_EQUAL,
    TOKEN_LESS,
    TOKEN_LESS_EQUAL,
    // Literals.
    TOKEN_IDENTIFIER,
    TOKEN_STRING,
    TOKEN_NUMBER,
    // Keywords.
    TOKEN_AND,
    TOKEN_CLASS,
    TOKEN_ELSE,
    TOKEN_FALSE,
    TOKEN_FOR,
    TOKEN_FUN,
    TOKEN_IF,
    TOKEN_NIL,
    TOKEN_OR,
    TOKEN_PRINT,
    TOKEN_RETURN,
    TOKEN_SUPER,
    TOKEN_THIS,
    TOKEN_TRUE,
    TOKEN_VAR,
    TOKEN_WHILE,

    TOKEN_ERROR,
    TOKEN_EOF,
};
pub const Scanner = struct {
    start: []u8,
    current: []u8,
    line: u8,
    pub fn init(start: []u8, current: []u8) Scanner {
        // may need to revisit here becuase we're passing in pointers to a string - however
        // maybe we can just keep track of it? It would be easier if we can just pass
        // that string and keep track of pointers - but let's see
        return .{ .start = start, .current = current, .line = 1 };
    }
    pub fn scanToken(self: *Scanner) Token {
        self.start = self.current;
        if (self.current.len == 1) return self.makeToken(TokenType.TOKEN_EOF);
        return TokenType.errorToken("Unexpected Character.\n");
    }
    // make token.
};

pub const Token = struct { type: TokenType, start: []u8, length: u32, line: u32 };
