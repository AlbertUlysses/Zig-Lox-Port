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
    start: []const u8,
    current: []const u8,
    line: u16,
    pub fn init(start: []const u8, current: []const u8) Scanner {
        return .{ .start = start, .current = current, .line = 1 };
    }
    fn isAlpha(c: u8) bool {
        return ((c >= 'a' and c <= 'z') or
            (c >= 'A' and c <= 'Z') or
            c == '_');
    }
    fn isDigit(c: u8) bool {
        return c >= '0' and c <= '9';
    }

    pub fn scanToken(self: *Scanner) Token {
        self.skipWhiteSpace();
        self.start = self.current;
        if (self.isAtEnd()) return self.makeToken(TokenType.TOKEN_EOF);
        const c = self.advance();
        if (self.isAlpha(c)) return self.identief();
        if (self.isDigit(c)) return self.number();
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
    fn checkKeyword(self: *Scanner, rest: []const u8, token_type: TokenType) TokenType {
        if (std.mem.eql(u8, self.current[1 .. rest.len + 1], rest)) return token_type;
    }
    fn identifierType(self: *Scanner) TokenType {
        switch (self.start[0]) {
            'a' => return self.checkKeyword("nd", .TOKEN_AND),
            'c' => return self.checkKeyword("lass", .TOKEN_CLASS),
            'e' => return self.checkKeyword("lse", .TOKEN_ELSE),
            'f' => {
                if (self.start.len > 0) {
                    switch (self.scanner.start[1]) {
                        'a' => return self.checkKeyword("lse", .TOKEN_FALSE),
                        'o' => return self.checkKeyword("r", .TOKEN_FOR),
                        'u' => return self.checkKeyword("n", .TOKEN_FUN),
                    }
                }
            },
            'i' => return self.checkKeyword("f", .TOKEN_IF),
            'n' => return self.checkKeyword("il", .TOKEN_NIL),
            'o' => return self.checkKeyword("r", .TOKEN_OR),
            'p' => return self.checkKeyword("rint", .TOKEN_PRINT),
            'r' => return self.checkKeyword("eturn", .TOKEN_RETURN),
            's' => return self.checkKeyword("uper", .TOKEN_SUPER),
            't' => return {
                if (self.start.len > 1) {
                    switch (self.start[1]) {
                        'h' => return self.checkKeyword("is", .TOKEN_THIS),
                        'r' => return self.checkKeyword("ue", .TOKEN_TRUE),
                    }
                }
            },
            'v' => return self.checkKeyword("ar", .TOKEN_VAR),
            'w' => return self.checkKeyword("hile", .TOKEN_WHILE),
        }
        return .TOKEN_IDENTIFIER;
    }

    fn identifier(self: *Scanner) Token {
        while (self.isAlpha(self.peek()) or self.isDigit(self.peek())) {
            self.advance();
        }
        return self.makeToken(self.identifierType());
    }
    fn number(self: *Scanner) void {
        while (self.isDigit(self.peek())) {
            self.advance();
        }
        // look for a fractional part
        if (self.peek() == '.' and self.isDigit(self.peekNext())) {
            //consume the '.'
            self.advance();
            // this is ugly but probably more optimized since we only check once
            // however it would also be infinite if we added it back up since we only check once
            // however it would also be infinite if we added it back up.
            while (self.isDigit(self.peek())) {
                self.advance();
            }
        }
        return self.makeToken(TokenType.TOKEN_NUMBER);
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
        if (self.isAtEnd()) return self.errorToken("Unterminated String.\n");
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
    fn errorToken(self: *Scanner, message: []const u8) Token {
        const token = Token.init(TokenType.TOKEN_ERROR, message, self.line);
        return token;
    }
};

pub const Token = struct {
    token_type: TokenType,
    start: []const u8,
    line: u16,
    pub fn init(token_type: TokenType, start: []const u8, line: u16) Token {
        return .{ .token_type = token_type, .start = start, .line = line };
    }
};
