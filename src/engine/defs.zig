pub const Color = enum { none, white, black };
pub const PieceType = enum { no_piece, pawn, bishop, knight, rook, queen, king };

pub const FileBits = enum(u64) { no_file = 0, A = 0x8080808080808080, B = 0x4040404040404040, C = 0x2020202020202020, D = 0x1010101010101010, E = 0x0808080808080808, F = 0x0404040404040404, G = 0x0202020202020202, H = 0x0101010101010101 };
pub const RankBits = enum(u64) { no_rank = 0, one = 0x00000000000000FF, two = 0x000000000000FF00, three = 0x0000000000FF0000, four = 0x00000000FF000000, five = 0x000000FF00000000, six = 0x0000FF0000000000, seven = 0x00FF000000000000, eight = 0xFF00000000000000 };
