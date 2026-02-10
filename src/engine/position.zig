const std = @import("std");
const d = @import("defs.zig");
const bb = @import("board.zig");
const utils = @import("utils.zig");

const PositionError = error{InvalidPosition};

pub const Position = struct {
    move: u64,
    plyCount: u64,
    turn: d.Color,
    last_pos: ?*Position,
    next_pos: ?*Position,
    en_pessant_sq: ?u64,
    white_castling: u8,
    black_castling: u8,
    white_pieces: [16]bb.Board,
    black_pieces: [16]bb.Board,

    pub fn init() Position {
        const white = [_]bb.Board{undefined} ** 16;
        const black = [_]bb.Board{undefined} ** 16;
        const empty_pos = Position{ .move = 0, .plyCount = 0, .turn = undefined, .last_pos = undefined, .next_pos = undefined, .white_castling = 0, .black_castling = 0, .en_pessant_sq = 0, .white_pieces = white, .black_pieces = black };
        return empty_pos;
    }

    /// TODO: add more checks for a valid position
    pub fn isValidPosition(self: Position) bool {
        // Check that white pieces and black pieces don't occupy the same square
        // This can be done with a bitwise XOR across all bitboards and should equal 0;
        var flag = false;
        var allBBs: bb.BitBoard = bb.emptyBitBoard;
        for (0..15) |idx| {
            allBBs = allBBs ^ self.white_pieces[idx].bitboard ^ self.black_pieces[idx].bitboard;
        }
        if (allBBs == bb.emptyBitBoard) {
            flag = true;
        }
        return flag;
    }

    pub fn print(self: Position) PositionError!void {
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
                for (self.white_pieces) |wp| {
                    if (wp.bitboard == &rank) {
                        std.debug.print("{c}", .{wp.getPieceChar()});
                        std.debug.print("{s}", .{div});
                        continue :file_letters;
                    }
                }
                for (self.black_pieces) |bp| {
                    if (bp.bitboard == file & rank) {
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
