const std = @import("std");

/// Different types of moves and their respective bits
/// Ref: https://www.chessprogramming.org/Encoding_Moves
pub const moveType = enum(u4) {
    quiet = 0,
    doublePawnPush = 1,
    kingCastle = 2,
    queenCastle = 3,
    capture = 4,
    epCapture = 5,
    knightPromo = 8,
    bishopPromo = 9,
    rookPromo = 10,
    queenPromo = 11,
    knightPromoCap = 12,
    bishopPromoCap = 13,
    rookPromoCap = 14,
    queenPromoCap = 15,
};

/// A struct representing a Move
/// from: square the piece is moving from
/// to: square the piece is moving to
/// score: the score of the move
/// moveFlags: flags giving info on the type of move
/// isCheck: is the move a check
pub const Move = struct {
    from: u6,
    to: u6,
    score: u8,
    moveFlags: u4,
    check: bool,

    /// Returns if a move is a capture
    pub fn isCapture(self: Move) bool {
        return self.moveFlags & 0x4;
    }

    /// Returns if a move is a promotion
    pub fn isPromotion(self: Move) bool {
        return self.moveFlags & 0x8;
    }

    /// Returns if move is a check
    /// Redundant to match other functions
    pub fn isCheck(self: Move) bool {
        return self.check;
    }

    /// Return the enum for the type of move
    pub fn getMoveType(self: Move) moveType {
        return @enumFromInt(self.moveFlags);
    }
};

test "moveType" {
    //bishop promo cap with check
    const m = Move{ .from = 1, .to = 2, .score = 0, .moveFlags = 13, .check = true };
    std.debug.print("{any}", .{m.getMoveType()});
}
