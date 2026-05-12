const std = @import("std");
const scanner = @import("scanner.zig");

pub fn compile(source: []u8) void {
    scanner = scanner.Scanner(source).init();
    var line: i8 = -1;
    while (true) {
        const token = scanner.scanToken();
        if (token.line != line) {
            std.debug.print("{4d} ", .{token.line});
            line = token.line;
        } else {
            std.debug.print("    | ", .{});
        }
        std.debug.print("{2d} '%.s'\n", .{ token.type, token.length, token.start });
        if (token.type == .TOKEN_EOF) break;
    }
}
