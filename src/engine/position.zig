const std = @import("std");
const d = @import("defs.zig");
const bb = @import("board.zig");

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

    // pub fn print(self: Position) void {
    //     const line = "   _ _ _ _ _ _ _ _ \n";
    //     const div = "|";
    //     const empty_sq = " ";
    //     const files = "abcdefgh";

    //     var rank: u8 = 8;
    //     std.debug.print("{s}", .{line});
    //     while (rank >= 1) : (rank -= 1) {
    //         std.debug.print("{d} {s}", .{ rank, div });
    //         file_letters: for (files) |file| {
    //             for (self.white_pieces) |wp| {
    //                 if (wp.getFileAsChar() == file and wp.getRankAsInt() == rank) {
    //                     std.debug.print("{c}", .{wp.pieceChar()});
    //                     std.debug.print("{s}", .{div});
    //                     continue :file_letters;
    //                 }
    //             }
    //             for (self.black_pieces) |bp| {
    //                 if (bp.getFileAsChar() == file and bp.getRankAsInt() == rank) {
    //                     std.debug.print("{c}", .{bp.pieceChar()});
    //                     std.debug.print("{s}", .{div});
    //                     continue :file_letters;
    //                 }
    //             }
    //             std.debug.print("{s}", .{empty_sq});
    //             std.debug.print("{s}", .{div});
    //         }
    //         std.debug.print("\n", .{});
    //     }
    //     std.debug.print("   A B C D E F G H ", .{});
    // }
};
