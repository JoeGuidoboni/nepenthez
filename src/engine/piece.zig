const d = @import("defs.zig");
const std = @import("std");

pub const Piece = struct {
    color: d.Color,
    piece_type: d.PieceType,
    rank: d.RankBits,
    file: d.FileBits,
    pub fn init() Piece {
        return Piece{ .color = undefined, .piece_type = undefined, .rank = undefined, .file = undefined };
    }

    pub fn getRankAsInt(self: *Piece) ?u32 {
        return d.RankToIntMap.get(self.rank);
    }

    pub fn getFileAsChar(self: *Piece) ?u8 {
        return d.FileToCharMap.get(self.file);
    }

    pub fn pieceChar(self: *Piece) u8 {
        var char: u8 = 0;
        if (self.color == d.Color.none or self.piece_type == d.PieceType.no_piece) {
            return char;
        }
        if (self.color == d.Color.black) {
            switch (self.piece_type) {
                d.PieceType.pawn => {
                    char = 'p';
                },
                d.PieceType.bishop => {
                    char = 'b';
                },
                d.PieceType.knight => {
                    char = 'n';
                },
                d.PieceType.rook => {
                    char = 'r';
                },
                d.PieceType.queen => {
                    char = 'q';
                },
                d.PieceType.king => {
                    char = 'k';
                },
                else => {
                    char = 0;
                },
            }
        } else {
            switch (self.piece_type) {
                d.PieceType.pawn => {
                    char = 'P';
                },
                d.PieceType.bishop => {
                    char = 'B';
                },
                d.PieceType.knight => {
                    char = 'N';
                },
                d.PieceType.rook => {
                    char = 'R';
                },
                d.PieceType.queen => {
                    char = 'Q';
                },
                d.PieceType.king => {
                    char = 'K';
                },
                else => {
                    char = 0;
                },
            }
        }
        return char;
    }

    pub fn prettyIcon(self: *Piece) !u21 {
        var icon: u21 = 0;
        if (self.color == d.Color.none or self.piece_type == d.PieceType.no_piece) {
            return icon;
        }
        if (self.color == d.Color.black) {
            switch (self.piece_type) {
                d.PieceType.pawn => {
                    icon = '♟';
                },
                d.PieceType.bishop => {
                    icon = '♝';
                },
                d.PieceType.knight => {
                    icon = '♞';
                },
                d.PieceType.rook => {
                    icon = '♜';
                },
                d.PieceType.queen => {
                    icon = '♛';
                },
                d.PieceType.king => {
                    icon = '♚';
                },
                else => {
                    icon = 0;
                },
            }
        } else {
            switch (self.piece_type) {
                d.PieceType.pawn => {
                    icon = '♙';
                },
                d.PieceType.bishop => {
                    icon = '♗';
                },
                d.PieceType.knight => {
                    icon = '♘';
                },
                d.PieceType.rook => {
                    icon = '♖';
                },
                d.PieceType.queen => {
                    icon = '♕';
                },
                d.PieceType.king => {
                    icon = '♔';
                },
                else => {
                    icon = 0;
                },
            }
        }
        return icon;
    }
};

test "unicode" {
    var piece: Piece = Piece.init();
    piece.color = d.Color.white;
    piece.piece_type = d.PieceType.pawn;
    std.debug.print("{any}\n", .{piece.prettyIcon()});
}

test "char" {
    var piece: Piece = Piece.init();
    piece.color = d.Color.white;
    piece.piece_type = d.PieceType.pawn;
    std.debug
        .print("{c}\n", .{piece.pieceChar()});
}

test "rank" {
    var piece: Piece = Piece.init();
    piece.rank = d.RankBits.one;
    std.debug.print("{d}\n", .{piece.getRankAsInt().?});
}

test "file" {
    var piece: Piece = Piece.init();
    piece.file = d.FileBits.A;
    std.debug.print("{c}\n", .{piece.getFileAsChar().?});
}
