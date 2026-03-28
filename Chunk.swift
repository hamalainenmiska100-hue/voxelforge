import Foundation

final class Chunk {
    static let size = 16

    let coord: ChunkCoord
    var blocks: [BlockType]
    var needsRemesh = true

    init(coord: ChunkCoord) {
        self.coord = coord
        self.blocks = Array(repeating: .air, count: Self.size * Self.size * Self.size)
    }

    @inline(__always)
    func index(_ x: Int, _ y: Int, _ z: Int) -> Int {
        x + Self.size * (y + Self.size * z)
    }

    @inline(__always)
    func get(_ x: Int, _ y: Int, _ z: Int) -> BlockType {
        blocks[index(x, y, z)]
    }

    @inline(__always)
    func set(_ x: Int, _ y: Int, _ z: Int, _ block: BlockType) {
        blocks[index(x, y, z)] = block
        needsRemesh = true
    }
}
