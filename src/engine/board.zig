const std = @import("std");
const d = @import("defs.zig");
const Color = d.Color;
const PieceType = d.PieceType;
const utils = @import("utils.zig");

pub const BitBoard = u64;
pub const emptyBitBoard = 0;

/// A bitboard representation of a chess board for a given color and piece type.
/// This implementation uses a PieceSet:
/// Each bitboard represents a single piece on the board
/// Pieces of the same type will each have their own bitboard, meaning theres 16 Boards for each side
pub const Board = struct {
    color: Color,
    pieceType: PieceType,
    bitboard: BitBoard,

    /// Inits a Board with a given color, piece, and bitboard
    pub fn init(color: Color, pieceType: PieceType, bitboard: BitBoard) Board {
        return Board{ .color = color, .pieceType = pieceType, .bitboard = bitboard };
    }

    /// Inits a Board with an empty bitboard for a given color and piece
    pub fn initEmpty(color: Color, pieceType: PieceType) Board {
        return init(color, pieceType, emptyBitBoard);
    }

    /// Returns the char that represents the piece of the Board
    pub fn getPieceChar(self: Board) u8 {
        return utils.colorAndPieceToChar(self.color, self.pieceType);
    }

    /// Checks if bitboard is empty
    pub fn isEmpty(self: Board) bool {
        return self.bitboard == emptyBitBoard;
    }
};
