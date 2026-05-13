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
    line: u16,
    pub fn init(start: []u8, current: []u8) Scanner {
        // may need to revisit here becuase we're passing in pointers to a string - however
        // maybe we can just keep track of it? It would be easier if we can just pass
        // that string and keep track of pointers - but let's see
        return .{ .start = start, .current = current, .line = 1 };
    }
    pub fn scanToken(self: *Scanner) Token {
        self.start = self.current;
        if (self.current.len == 1) return self.makeToken(TokenType.TOKEN_EOF);
        const c = self.advance();
        switch (c) {
            '(' => return self.makeToken(TokenType.TOKEN_LEFT_PAREN),
            ')' => return self.makeToken(TokenType.TOKEN_RIGHT_PAREN),
            '{' => return self.makeToken(TokenType.TOKEN_LEFT_BRACE),
            '}' => return self.makeToken(TokenType.TOKEN_RIGHT_BRACE),
            ';' => return self.makeToken(TokenType.TOKEN_SEMICOLON),
            ',' => return self.makeToken(TokenType.TOKEN_COMMA),
            '.' => return self.makeToken(TokenType.TOKEN_DOT),
            '-' => return self.makeToken(TokenType.TOKEN_MINUS),
            '+' => return self.makeToken(TokenType.TOKEN_PLUS),
            '/' => return self.makeToken(TokenType.TOKEN_SLASH),
            '*' => return self.makeToken(TokenType.TOKEN_STAR),
            else => return TokenType.errorToken,
        }
        return Token.initError("Unexpected Character.\n");
    }
    fn advance(self: *Scanner) []u8 {
        defer self.current = self.current[1..];
        return self.current[0..];
    }
    pub fn makeToke(self: *Scanner, token_type: TokenType) Token {
        const token = Token().init(token_type, self.start, self.line);
        return token;
    }
};

pub const Token = struct {
    token_type: TokenType,
    start: []u8,
    line: u16,
    pub fn init(token_type: TokenType, start: []u8, line: u16) Token {
        return .{ .token_type = token_type, .start = start, .line = line };
    }
    pub fn initError(start: []u8, line: u16) Token {
        return .{ .token_type = TokenType.TOKEN_ERROR, .start = start, .line = line };
    }
};
