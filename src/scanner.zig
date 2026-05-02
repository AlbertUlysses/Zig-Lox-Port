const std = @import("std");
pub const Scanner = struct {
    start: u8,
    current: u8,
    line: u8,
    pub fn init(source: u8) Scanner {
        // may need to revisit here becuase we're passing in pointers to a string - however
        // maybe we can just keep track of it? It would be easier if we can just pass
        // that string and keep track of pointers - but let's see
        return .{ .start = source, .current = source, .line = 1 };
    }
};
