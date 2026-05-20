const std = @import("std");
const scanner = @import("scanner.zig");

const Parser = struct{
    scanner: *scanner.Scanner,
    current: scanner.Token,
    previous: scanner.Token,

    pub fn advance(self: *Parser) void {
        self.previous = self.current;
        while(true){
            self.current = self.scanner.scanToken();
            if(self.current.token_type != scanner.TokenType.TOKEN_ERROR) break;
            self.errorAtCurrent(self.current.start);
        }
    }
};
pub fn compile(source: []const u8) bool {
    scanner = scanner.Scanner(source).init();
    // parser init
    self.advance();
    self.expression();
    self.consumer(.TOKEN_EOF, "Expect end of Expression.");
}

