const std = @import("std");
const print = std.debug.print;
const utils = @import("engine/utils.zig");
const d = @import("engine/defs.zig");
const position = @import("engine/position.zig");

pub fn main() !void {
    print("{s}\n\n\n", .{d.banner});

    const starting_pos = try utils.fenToPosition("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1");
    try starting_pos.print();
}
