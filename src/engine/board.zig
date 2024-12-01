const std = @import("std");
const d = @import("defs.zig");

pub const BitBoard = struct { color: d.Color, piece: d.PieceType, rankbits: d.RankBits, filebits: d.FileBits };

pub fn bbFromRankAndFile(rank: d.RankBits, file: d.FileBits) u64 {
    return @intFromEnum(rank) & @intFromEnum(file);
}
