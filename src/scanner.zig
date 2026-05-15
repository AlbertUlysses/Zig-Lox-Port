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
        self.skipWhiteSpace();
        self.start = self.current;
        if (self.isAtEnd()) return self.makeToken(TokenType.TOKEN_EOF);
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
            '!' => return self.makeToken(if (self.match('=')) TokenType.TOKEN_BANG_EQUAL else TokenType.TOKEN_BANG),
            '=' => return self.makeToken(if (self.match('=')) TokenType.TOKEN_EQUAL_EQUAL else TokenType.TOKEN_EQUAL),
            '<' => return self.makeToken(if (self.match('=')) TokenType.TOKEN_LESS_EQUAL else TokenType.TOKEN_LESS),
            '>' => return self.makeToken(if (self.match('=')) TokenType.TOKEN_GREATER_EQUAL else TokenType.TOKEN_GREATER),
            '"' => return self.string(),
            else => return TokenType.TOKEN_ERROR,
        }
        return self.makeTokenError("Unexpected Character.\n");
    }
    fn skipWhiteSpace(self: *Scanner) void {
        while (true) {
            const c: u8 = self.peek();
            switch (c) {
                ' ', 'r', '\t' => self.advance(),
                '\n' => {
                    self.line += 1;
                    self.advance();
                },
                '/' => {
                    if (self.peekNext() == '/') {
                        while (self.peek() != '\n' and !(self.isAtEnd())) {
                            self.advance();
                        }
                    } else {
                        return;
                    }
                },
                else => return,
            }
        }
    }
    fn isAtEnd(self: *Scanner) bool {
        return self.current.len == 0;
    }
    fn string(self: *Scanner) Token {
        while (self.peek() != '"' and !(self.isAtEnd())) {
            if (self.peek() == '\n') {
                self.line += 1;
            }
            self.advanace();
        }
        if (self.isAtEnd()) return Token.initError("Unterminated String.\n");
        self.advance();
        self.makeToken(TokenType.TOKEN_STRING);
    }
    fn match(self: *Scanner, expected: u8) bool {
        if (self.isAtEnd()) return false;
        if (self.current != expected) return false;
        self.current = self.current[1..];
        return true;
    }
    fn peek(self: *Scanner) u8 {
        return self.current[0];
    }
    fn advance(self: *Scanner) []u8 {
        defer self.current = self.current[1..];
        return self.current[0];
    }
    fn peekNext(self: *Scanner) ?u8 {
        if (self.isAtEnd()) return null;
        return self.current[1];
    }
    fn makeToken(self: *Scanner, token_type: TokenType) Token {
        const token = Token.init(token_type, self.start, self.line);
        return token;
    }
    // fix this and remove initError need to see if we can pass a string into TOken
    // maybe using a union?
    fn errorToken(self: *Scanner, ){}
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
