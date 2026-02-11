const std = @import("std");
const d = @import("defs.zig");
const Color = d.Color;
const PieceType = d.PieceType;
const RankBits = d.RankBits;
const FileBits = d.FileBits;
const position = @import("position.zig");
const bb = @import("board.zig");

// errors
const UtilsError = error{ RankConversion, FileConversion, FENConversion, BadPieceInfo, CoordConversion };

pub fn fenToPosition(fen: []const u8) !position.Position {
    var fenPosition = position.Position.init();

    // separate the 6 fen fields
    var spaceIdx = [_]usize{0} ** 5;
    var spaceCount: u32 = 0;
    for (fen, 0..) |char, index| {
        if (char == ' ') {
            spaceIdx[spaceCount] = index;
            spaceCount += 1;
        }
    }

    const positionStringSlice = fen[0..spaceIdx[0]];
    const sideToMoveSlice = fen[spaceIdx[0] + 1 .. spaceIdx[1]];
    const castlingRightsSlice = fen[spaceIdx[1] + 1 .. spaceIdx[2]];
    // const enPassantSqSlice = fen[spaceIdx[2] + 1 .. spaceIdx[3]];
    const plyClockSlice = fen[spaceIdx[3] + 1 .. spaceIdx[4]];
    const moveNumberSlice = fen[spaceIdx[4] + 1 ..];

    // const enPessantSq = if (!std.mem.eql(u8, "-", enPassantSqSlice)) try coordToBitBoard(enPassantSqSlice) else undefined;
    const sideToMove = if (std.mem.eql(u8, sideToMoveSlice, "w")) Color.white else if (std.mem.eql(u8, sideToMoveSlice, "b")) Color.black else undefined;
    var whiteCastling: u2 = 0;
    var blackCastling: u2 = 0;
    if (!std.mem.eql(u8, castlingRightsSlice, "-")) {
        for (castlingRightsSlice) |castleChar| {
            switch (castleChar) {
                'K' => whiteCastling += 1,
                'Q' => whiteCastling += 2,
                'k' => blackCastling += 1,
                'q' => blackCastling += 2,
                else => unreachable,
            }
        }
    }
    const plyClock = try std.fmt.parseInt(u32, plyClockSlice, 10);
    const moveNumber = try std.fmt.parseInt(u32, moveNumberSlice, 10);

    // parse position
    var slashIdx = [_]usize{0} ** 7;
    var slashCount: u32 = 0;
    for (positionStringSlice, 0..) |char, index| {
        if (char == '/') {
            slashIdx[slashCount] = index;
            slashCount += 1;
        }
    }

    const rank8slice = positionStringSlice[0..slashIdx[0]];
    const rank7slice = positionStringSlice[slashIdx[0] + 1 .. slashIdx[1]];
    const rank6slice = positionStringSlice[slashIdx[1] + 1 .. slashIdx[2]];
    const rank5slice = positionStringSlice[slashIdx[2] + 1 .. slashIdx[3]];
    const rank4slice = positionStringSlice[slashIdx[3] + 1 .. slashIdx[4]];
    const rank3slice = positionStringSlice[slashIdx[4] + 1 .. slashIdx[5]];
    const rank2slice = positionStringSlice[slashIdx[5] + 1 .. slashIdx[6]];
    const rank1slice = positionStringSlice[slashIdx[6] + 1 ..];

    const rankSlices = [8][]const u8{ rank1slice, rank2slice, rank3slice, rank4slice, rank5slice, rank6slice, rank7slice, rank8slice };

    var whitePieces = [_]bb.Board{undefined} ** 16;
    var blackPieces = [_]bb.Board{undefined} ** 16;
    var whiteIdx: u32 = 0;
    var blackIdx: u32 = 0;

    for (rankSlices, 0..rankSlices.len) |slice, sliceIdx| {
        const rankIdx = sliceIdx + 1;
        var fileIdx: u32 = 1;
        for (slice, 0..slice.len) |symbol, _| {

            // if char is not a number, its a piece
            if (!isNum(symbol)) {
                const p = try charToBoard(symbol, try intToRankBits(rankIdx), try intToFileBits(fileIdx));
                if (p.color == Color.white) {
                    whitePieces[whiteIdx] = p;
                    whiteIdx += 1;
                } else if (p.color == Color.black) {
                    blackPieces[blackIdx] = p;
                    blackIdx += 1;
                }
                fileIdx += 1;
            } else { // char is a number the number of squares it is
                fileIdx += try std.fmt.parseInt(u32, slice, 10);
            }
        }
    }

    fenPosition.plyCount = plyClock;
    fenPosition.turn = sideToMove;
    fenPosition.move50 = moveNumber;
    fenPosition.whiteCastling = whiteCastling;
    fenPosition.blackCastling = blackCastling;
    fenPosition.whitePieces = whitePieces;
    fenPosition.blackPieces = blackPieces;
    // fenPosition.en_pessant_sq = enPessantSq;
    return fenPosition;
}

fn charToBoard(char: u8, rank: RankBits, file: FileBits) !bb.Board {
    var c: Color = Color.none;
    var pt: PieceType = PieceType.no_piece;
    switch (char) {
        'p' => {
            c = Color.black;
            pt = PieceType.pawn;
        },
        'b' => {
            c = Color.black;
            pt = PieceType.bishop;
        },
        'n' => {
            c = Color.black;
            pt = PieceType.knight;
        },
        'r' => {
            c = Color.black;
            pt = PieceType.rook;
        },
        'q' => {
            c = Color.black;
            pt = PieceType.queen;
        },
        'k' => {
            c = Color.black;
            pt = PieceType.king;
        },
        'P' => {
            c = Color.white;
            pt = PieceType.pawn;
        },
        'B' => {
            c = Color.white;
            pt = PieceType.bishop;
        },
        'N' => {
            c = Color.white;
            pt = PieceType.knight;
        },
        'R' => {
            c = Color.white;
            pt = PieceType.rook;
        },
        'Q' => {
            c = Color.white;
            pt = PieceType.queen;
        },
        'K' => {
            c = Color.white;
            pt = PieceType.king;
        },
        else => {
            return UtilsError.BadPieceInfo;
        },
    }
    const newBoard = bb.Board{ .color = c, .pieceType = pt, .bitboard = bbFromRankAndFile(rank, file) };
    return newBoard;
}

pub fn colorAndPieceToChar(color: Color, pieceType: PieceType) u8 {
    if (color == Color.none or pieceType == PieceType.no_piece) return '_';

    const char: u8 = switch (pieceType) {
        PieceType.pawn => 'p',
        PieceType.bishop => 'b',
        PieceType.knight => 'n',
        PieceType.rook => 'r',
        PieceType.queen => 'q',
        PieceType.king => 'k',
        else => '_',
    };

    if (color == Color.white) {
        return std.ascii.toUpper(char);
    }

    return char;
}

pub fn intToRankBits(rankNum: u64) !RankBits {
    switch (rankNum) {
        1 => {
            return RankBits.one;
        },
        2 => {
            return RankBits.two;
        },
        3 => {
            return RankBits.three;
        },
        4 => {
            return RankBits.four;
        },
        5 => {
            return RankBits.five;
        },
        6 => {
            return RankBits.six;
        },
        7 => {
            return RankBits.seven;
        },
        8 => {
            return RankBits.eight;
        },
        else => {
            return UtilsError.RankConversion;
        },
    }
}

pub fn intToFileBits(fileNum: u64) !FileBits {
    switch (fileNum) {
        1 => {
            return FileBits.A;
        },
        2 => {
            return FileBits.B;
        },
        3 => {
            return FileBits.C;
        },
        4 => {
            return FileBits.D;
        },
        5 => {
            return FileBits.E;
        },
        6 => {
            return FileBits.F;
        },
        7 => {
            return FileBits.G;
        },
        8 => {
            return FileBits.H;
        },
        else => {
            return UtilsError.FileConversion;
        },
    }
}

pub fn charToFileBits(fileChar: u8) !FileBits {
    switch (fileChar) {
        'a', 'A' => {
            return FileBits.A;
        },
        'b', 'B' => {
            return FileBits.B;
        },
        'c', 'C' => {
            return FileBits.C;
        },
        'd', 'D' => {
            return FileBits.D;
        },
        'e', 'E' => {
            return FileBits.E;
        },
        'f', 'F' => {
            return FileBits.F;
        },
        'g', 'G' => {
            return FileBits.G;
        },
        'h', 'H' => {
            return FileBits.H;
        },
        else => {
            return UtilsError.FileConversion;
        },
    }
}

pub fn coordToRankAndFile(coord: []const u8) !struct { rank: RankBits, file: FileBits } {
    if (coord.len != 2 || !isNum(coord[1])) return UtilsError.CoordConversion;
    return .{ .rank = try intToRankBits(coord[1]), .file = try charToFileBits(coord[0]) };
}

pub fn bbFromRankAndFile(rank: RankBits, file: FileBits) bb.BitBoard {
    return @intFromEnum(rank) & @intFromEnum(file);
}

pub fn coordToBitBoard(coord: []const u8) !u64 {
    const rankAndFile = try coordToRankAndFile(coord);
    return try bbFromRankAndFile(rankAndFile.rank, rankAndFile.file);
}

pub fn isNum(char: u8) bool {
    const str = [1]u8{char};
    _ = std.fmt.parseInt(u32, &str, 10) catch {
        return false;
    };
    return true;
}
