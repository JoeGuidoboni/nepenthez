const d = @import("defs.zig");

pub const Piece = struct {
    color: d.Color,
    piece_type: d.PieceType,
    rank: d.RankBits,
    file: d.FileBits,
    pub fn init() Piece {
        return Piece{ .color = undefined, .piece_type = undefined, .rank = undefined, .file = undefined };
    }
};
