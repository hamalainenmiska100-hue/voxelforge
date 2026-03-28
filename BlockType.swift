import simd

enum BlockType: UInt8, CaseIterable {
    case air = 0
    case grass = 1
    case dirt = 2
    case stone = 3

    var isSolid: Bool { self != .air }

    var atlasTileIndex: Int {
        switch self {
        case .air: return 0
        case .grass: return 0
        case .dirt: return 1
        case .stone: return 2
        }
    }

    func atlasTileIndex(for face: BlockFace) -> Int {
        switch self {
        case .air:
            return 0
        case .grass:
            switch face {
            case .top: return 0
            case .bottom: return 1
            default: return 3
            }
        case .dirt:
            return 1
        case .stone:
            return 2
        }
    }
}

enum BlockFace: Int, CaseIterable {
    case top = 0
    case bottom = 1
    case left = 2
    case right = 3
    case front = 4
    case back = 5
}
