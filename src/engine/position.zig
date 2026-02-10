const std = @import("std");
const Color = @import("defs.zig").Color;
const PieceType = @import("defs.zig").PieceType;
const bb = @import("board.zig");
const utils = @import("utils.zig");

const PositionError = error{InvalidPosition};

/// A struct representing a position
/// Contains
/// - move50: counter for the fifty move rule
/// - ply: counter for ply (half-turns)
/// - turn: which color's turn
/// - lastPos: reference to last Position, if there is one
/// - nextPos: reference to next Position, if there is one
/// - enPessantSq: en pessant square, if there is one
/// - whiteCastling: byte representing white castling privilege
/// - blackCastling: byte representing black castling privilege
/// - whitePieces: array of Boards representing white's pieces
/// - blackPieces: array of Boards representing black's pieces
pub const Position = struct {
    move50: u64 = 0,
    plyCount: u64 = 0,
    turn: Color = Color.none,
    lastPos: ?*Position = null,
    nextPos: ?*Position = null,
    enPessantSq: ?u64 = null,
    whiteCastling: u8 = 0,
    blackCastling: u8 = 0,
    whitePieces: [16]bb.Board,
    blackPieces: [16]bb.Board,

    pub fn init() Position {
        const white = [_]bb.Board{undefined} ** 16;
        const black = [_]bb.Board{undefined} ** 16;
        const empty_pos = Position{ .move50 = 0, .plyCount = 0, .turn = undefined, .lastPos = undefined, .nextPos = undefined, .whiteCastling = 0, .blackCastling = 0, .enPessantSq = 0, .whitePieces = white, .blackPieces = black };
        return empty_pos;
    }

    /// TODO: add more checks for a valid position
    pub fn isValidPosition(self: Position) bool {
        // Check that white pieces and black pieces don't occupy the same square
        // This can be done with a bitwise XOR across all bitboards which should equal 0;
        var flag = false;
        var allBBs: bb.BitBoard = bb.emptyBitBoard;
        for (0..15) |idx| {
            allBBs = allBBs ^ self.whitePieces[idx].bitboard ^ self.blackPieces[idx].bitboard;
        }
        if (allBBs == bb.emptyBitBoard) {
            flag = true;
        }
        return flag;
    }

    /// Prints the current position
    /// TODO: add additional FEN information
    ///
    /// Prints the position from whites perspective with A1 in the bottom left and H8 in the top right
    pub fn print(self: Position) !void {
        if (self.isValidPosition()) return PositionError.InvalidPosition;

        const line = "   _ _ _ _ _ _ _ _ \n";
        const div = "|";
        const empty_sq = " ";
        const files = "abcdefgh";

        std.debug.print("{s}", .{line});

        var rank: u8 = 8;
        while (rank >= 1) : (rank -= 1) {
            std.debug.print("{d} {s}", .{ rank, div });
            file_letters: for (files) |file| {
                for (self.whitePieces) |wp| {
                    const fileBits = try utils.charToFileBits(file);
                    const rankBits = try utils.intToRankBits(rank);
                    if (wp.bitboard == @intFromEnum(fileBits) & @intFromEnum(rankBits)) {
                        std.debug.print("{c}", .{wp.getPieceChar()});
                        std.debug.print("{s}", .{div});
                        continue :file_letters;
                    }
                }
                for (self.blackPieces) |bp| {
                    const fileBits = try utils.charToFileBits(file);
                    const rankBits = try utils.intToRankBits(rank);
                    if (bp.bitboard == @intFromEnum(fileBits) & @intFromEnum(rankBits)) {
                        std.debug.print("{c}", .{bp.getPieceChar()});
                        std.debug.print("{s}", .{div});
                        continue :file_letters;
                    }
                }
                std.debug.print("{s}", .{empty_sq});
                std.debug.print("{s}", .{div});
            }
            std.debug.print("\n", .{});
        }

        std.debug.print("   A B C D E F G H ", .{});
    }
};
