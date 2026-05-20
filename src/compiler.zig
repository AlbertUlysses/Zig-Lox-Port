const std = @import("std");
const scanner = @import("scanner.zig");

const Parser = struct {
    scanner: *scanner.Scanner,
    current: ?scanner.Token,
    previous: ?scanner.Token,
    hadError: bool,
    // have the current and previous as null could cause issues but ideally it stays as
    // null only for iteration
    pub fn init(init_scanner: *scanner.Scanner) Parser {
        return .{ .scanner = init_scanner, .current = null, .previous = null, .hadError = false };
    }

    pub fn advance(self: *Parser) void {
        self.previous = self.current;
        while (true) {
            self.current = self.scanner.scanToken();
            if (self.current.token_type != scanner.TokenType.TOKEN_ERROR) break;
            self.errorAtCurrent(self.current.start);
        }
    }
    fn errorAtCurrent(self: *Parser, message: []const u8) void {
        self.errorAt(self.previous, message);
    }
    fn errorAt(self: *Parser, token: scanner.Token, message: []const u8) void {
        // this should be a standard error
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

pub fn compile(source: []const u8) bool {
    scanner = scanner.Scanner(source).init();
    // parser code is only defined and used here
    const parser = Parser.init(scanner);
    parser.advance();
    parser.expression();
    parser.consumer(.TOKEN_EOF, "Expect end of Expression.");
}
