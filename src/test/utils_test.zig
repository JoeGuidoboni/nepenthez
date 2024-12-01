const std = @import("std");
const expect = std.testing.expect;
const utils = @import("../utils.zig");

test "int" {
    try expect(utils.isNum("6") == 6);
}
