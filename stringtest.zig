const std = @import("std");

pub fn main() void {
    var word = "1hello";
    const word2 = " world\n";
    word = word[1..];
    std.debug.print("{s}, {s}", .{ word, word2 });
}
