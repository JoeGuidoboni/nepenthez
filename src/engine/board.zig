const std = @import("std");
const d = @import("defs.zig");

pub const BitBoard = u64;
pub const emptyBitBoard = 0;

/// A bitboard representation of a chess board for a given color and piece type.
/// Each bitboard represents a single piece on the board
/// Pieces of the same type will each have their own bitboard
pub const Board = struct {
    color: d.Color,
    pieceType: d.PieceType,
    bitboard: BitBoard,

    pub fn init(color: d.Color, pieceType: d.PieceType, bitboard: BitBoard) Board {
        return Board{ .color = color, .pieceType = pieceType, .bitboard = bitboard };
    }

    pub fn initEmpty(color: d.Color, pieceType: d.PieceType) Board {
        return init(color, pieceType, emptyBitBoard);
    }
};
