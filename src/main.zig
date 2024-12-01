const std = @import("std");
const utils = @import("utils.zig");
const position = @import("engine/position.zig");

pub fn main() !void {
    const starting_pos = try utils.fenToPosition("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1");
    std.debug.print("{any}", .{starting_pos});
    // const num = utils.isNum("t890s");
    // std.debug.print("{any}", .{num});
}
