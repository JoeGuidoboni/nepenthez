const std = @import("std");
const d = @import("defs.zig");
const position = @import("position.zig");
const bb = @import("board.zig");

// errors
const UtilsError = error{ RankConversion, FileConversion, FENConversion, BadPieceInfo, CoordConversion };

const banner =
    \\  __   _ _______  _____  _______ __   _ _______ _     _ _______ ______
    \\  | \  | |______ |_____] |______ | \  |    |    |_____| |______  ____/
    \\  |  \_| |______ |       |______ |  \_|    |    |     | |______ /_____
;

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
    // const castlingRightsSlice = fen[spaceIdx[1] + 1 .. spaceIdx[2]];
    // const enPassantSqSlice = fen[spaceIdx[2] + 1 .. spaceIdx[3]];
    const plyClockSlice = fen[spaceIdx[3] + 1 .. spaceIdx[4]];
    const moveNumberSlice = fen[spaceIdx[4] + 1 ..];

    // get the easy ones
    // const enPessantSq = if (!std.mem.eql(u8, "-", enPassantSqSlice)) try coordToBitBoard(enPassantSqSlice) else undefined;
    const sideToMove = if (std.mem.eql(u8, sideToMoveSlice, "w")) d.Color.white else if (std.mem.eql(u8, sideToMoveSlice, "b")) d.Color.black else undefined;
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
                if (p.color == d.Color.white) {
                    whitePieces[whiteIdx] = p;
                    whiteIdx += 1;
                } else if (p.color == d.Color.black) {
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
    fenPosition.move = moveNumber;
    fenPosition.white_pieces = whitePieces;
    fenPosition.black_pieces = blackPieces;
    // fenPosition.en_pessant_sq = enPessantSq;
    return fenPosition;
}

fn charToBoard(char: u8, rank: d.RankBits, file: d.FileBits) !bb.Board {
    var c: d.Color = d.Color.none;
    var pt: d.PieceType = d.PieceType.no_piece;
    switch (char) {
        'p' => {
            c = d.Color.black;
            pt = d.PieceType.pawn;
        },
        'b' => {
            c = d.Color.black;
            pt = d.PieceType.bishop;
        },
        'n' => {
            c = d.Color.black;
            pt = d.PieceType.knight;
        },
        'r' => {
            c = d.Color.black;
            pt = d.PieceType.rook;
        },
        'q' => {
            c = d.Color.black;
            pt = d.PieceType.queen;
        },
        'k' => {
            c = d.Color.black;
            pt = d.PieceType.king;
        },
        'P' => {
            c = d.Color.white;
            pt = d.PieceType.pawn;
        },
        'B' => {
            c = d.Color.white;
            pt = d.PieceType.bishop;
        },
        'N' => {
            c = d.Color.white;
            pt = d.PieceType.knight;
        },
        'R' => {
            c = d.Color.white;
            pt = d.PieceType.rook;
        },
        'Q' => {
            c = d.Color.white;
            pt = d.PieceType.queen;
        },
        'K' => {
            c = d.Color.white;
            pt = d.PieceType.king;
        },
        else => {
            return UtilsError.BadPieceInfo;
        },
    }
    const newBoard = bb.Board{ .color = c, .pieceType = pt, .bitboard = bbFromRankAndFile(rank, file) };
    return newBoard;
}

pub fn colorAndPieceToChar(color: d.Color, pieceType: d.PieceType) u8 {
    if (color == d.Color.none or pieceType == d.PieceType.no_piece) return '_';

    const char: u8 = switch (pieceType) {
        d.PieceType.pawn => 'p',
        d.PieceType.bishop => 'b',
        d.PieceType.knight => 'n',
        d.PieceType.rook => 'r',
        d.PieceType.queen => 'q',
        d.PieceType.king => 'k',
        else => '_',
    };

    if (color == d.Color.white) {
        return std.ascii.toUpper(char);
    }

    return char;
}

pub fn intToRankBits(rankNum: u64) !d.RankBits {
    switch (rankNum) {
        1 => {
            return d.RankBits.one;
        },
        2 => {
            return d.RankBits.two;
        },
        3 => {
            return d.RankBits.three;
        },
        4 => {
            return d.RankBits.four;
        },
        5 => {
            return d.RankBits.five;
        },
        6 => {
            return d.RankBits.six;
        },
        7 => {
            return d.RankBits.seven;
        },
        8 => {
            return d.RankBits.eight;
        },
        else => {
            return UtilsError.RankConversion;
        },
    }
}

pub fn intToFileBits(fileNum: u64) !d.FileBits {
    switch (fileNum) {
        1 => {
            return d.FileBits.A;
        },
        2 => {
            return d.FileBits.B;
        },
        3 => {
            return d.FileBits.C;
        },
        4 => {
            return d.FileBits.D;
        },
        5 => {
            return d.FileBits.E;
        },
        6 => {
            return d.FileBits.F;
        },
        7 => {
            return d.FileBits.G;
        },
        8 => {
            return d.FileBits.H;
        },
        else => {
            return UtilsError.FileConversion;
        },
    }
}

pub fn charToFileBits(fileChar: u8) !d.FileBits {
    switch (fileChar) {
        'a', 'A' => {
            return d.FileBits.A;
        },
        'b', 'B' => {
            return d.FileBits.B;
        },
        'c', 'C' => {
            return d.FileBits.C;
        },
        'd', 'D' => {
            return d.FileBits.D;
        },
        'e', 'E' => {
            return d.FileBits.E;
        },
        'f', 'F' => {
            return d.FileBits.F;
        },
        'g', 'G' => {
            return d.FileBits.G;
        },
        'h', 'H' => {
            return d.FileBits.H;
        },
        else => {
            return UtilsError.FileConversion;
        },
    }
}

pub fn coordToRankAndFile(coord: []const u8) !struct { rank: d.RankBits, file: d.FileBits } {
    if (coord.len != 2 || !isNum(coord[1])) return UtilsError.CoordConversion;
    return .{ .rank = try intToRankBits(coord[1]), .file = try charToFileBits(coord[0]) };
}

pub fn bbFromRankAndFile(rank: d.RankBits, file: d.FileBits) bb.BitBoard {
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
