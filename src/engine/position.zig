const std = @import("std");
const print = std.debug.print;
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
/// - whiteCastling: u2 representing white castling privilege. 01 is kingside, 10 is queenside, 11 is both
/// - blackCastling: u2 representing black castling privilege. 01 is kingside, 10 is queenside, 11 is both
/// - whitePieces: array of Boards representing white's pieces
/// - blackPieces: array of Boards representing black's pieces
pub const Position = struct {
    move50: u64 = 0,
    plyCount: u64 = 0,
    turn: Color = Color.none,
    lastPos: ?*Position = null,
    nextPos: ?*Position = null,
    enPessantSq: ?u64 = null,
    whiteCastling: u2 = 0,
    blackCastling: u2 = 0,
    whitePieces: [16]bb.Board,
    blackPieces: [16]bb.Board,

    pub fn init() Position {
        const white = [_]bb.Board{undefined} ** 16;
        const black = [_]bb.Board{undefined} ** 16;
        const empty_pos = Position{ .move50 = 0, .plyCount = 0, .turn = undefined, .lastPos = undefined, .nextPos = undefined, .whiteCastling = 0, .blackCastling = 0, .enPessantSq = 0, .whitePieces = white, .blackPieces = black };
        return empty_pos;
    }

    /// Prints the current position
    /// TODO: add additional FEN information
    ///
    /// Prints the position from whites perspective with A1 in the bottom left and H8 in the top right
    pub fn printPosition(self: Position) !void {
        if (utils.isValidPosition(self)) return PositionError.InvalidPosition;

        const line = "   _ _ _ _ _ _ _ _ \n";
        const div = "|";
        const empty_sq = " ";
        const files = "abcdefgh";

        print("{s}", .{line});

        var rank: u8 = 8;
        while (rank >= 1) : (rank -= 1) {
            print("{d} {s}", .{ rank, div });
            file_letters: for (files) |file| {
                for (self.whitePieces) |wp| {
                    const fileBits = try utils.charToFileBits(file);
                    const rankBits = try utils.intToRankBits(rank);
                    if (wp.bitboard == @intFromEnum(fileBits) & @intFromEnum(rankBits)) {
                        print("{c}", .{wp.getPieceChar()});
                        print("{s}", .{div});
                        continue :file_letters;
                    }
                }
                for (self.blackPieces) |bp| {
                    const fileBits = try utils.charToFileBits(file);
                    const rankBits = try utils.intToRankBits(rank);
                    if (bp.bitboard == @intFromEnum(fileBits) & @intFromEnum(rankBits)) {
                        print("{c}", .{bp.getPieceChar()});
                        print("{s}", .{div});
                        continue :file_letters;
                    }
                }
                print("{s}", .{empty_sq});
                print("{s}", .{div});
            }
            print("\n", .{});
        }

        print("   A B C D E F G H ", .{});
        print("\n\n\n", .{});
        print("Ply:\t{d}\n", .{self.plyCount});
        print("Side to move:\t{s}\n", .{@tagName(self.turn)});
        print("White castling rights:\t.{b}\n", .{self.whiteCastling});
        print("Black castling rights:\t.{b}\n", .{self.blackCastling});
    }
};
