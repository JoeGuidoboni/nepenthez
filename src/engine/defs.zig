const std = @import("std");

pub const Color = enum { none, white, black };
pub const PieceType = enum { no_piece, pawn, bishop, knight, rook, queen, king };

pub const FileBits = enum(u64) { no_file = 0, A = 0x8080808080808080, B = 0x4040404040404040, C = 0x2020202020202020, D = 0x1010101010101010, E = 0x0808080808080808, F = 0x0404040404040404, G = 0x0202020202020202, H = 0x0101010101010101 };
pub const RankBits = enum(u64) { no_rank = 0, one = 0x00000000000000FF, two = 0x000000000000FF00, three = 0x0000000000FF0000, four = 0x00000000FF000000, five = 0x000000FF00000000, six = 0x0000FF0000000000, seven = 0x00FF000000000000, eight = 0xFF00000000000000 };

pub const FileToCharMap = std.enums.EnumMap(FileBits, u8).init(.{
    .no_file = 0,
    .A = 'A',
    .B = 'B',
    .C = 'C',
    .D = 'D',
    .E = 'E',
    .F = 'F',
    .G = 'G',
    .H = 'H',
});

pub const RankToIntMap = std.enums.EnumMap(RankBits, u32).init(.{
    .no_rank = 0,
    .one = 1,
    .two = 2,
    .three = 3,
    .four = 4,
    .five = 5,
    .six = 6,
    .seven = 7,
    .eight = 8,
});

test "File2CharMap" {
    std.debug.print("{c}\n", .{FileToCharMap.get(FileBits.A).?});
}

test "Rank2IntMap" {
    std.debug.print("{d}\n", .{RankToIntMap.get(RankBits.one).?});
}
