const std = @import("std");
const piece = @import("piece.zig");
const d = @import("defs.zig");

pub const Position = struct {
    move: u64,
    plyCount: u64,
    turn: d.Color,
    last_pos: ?*Position,
    next_pos: ?*Position,
    en_pessant_sq: ?u64,
    white_castling: u8,
    black_castling: u8,
    white_pieces: [16]piece.Piece,
    black_pieces: [16]piece.Piece,

    pub fn init() Position {
        const empty_pos = Position{ .move = 0, .plyCount = 0, .turn = undefined, .last_pos = undefined, .next_pos = undefined, .white_castling = 0, .black_castling = 0, .en_pessant_sq = 0, .white_pieces = [_]piece.Piece{undefined} ** 16, .black_pieces = [_]piece.Piece{undefined} ** 16 };
        return empty_pos;
    }
};
