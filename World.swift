import Foundation
import simd

final class World {
    var chunks: [ChunkCoord: Chunk] = [:]
    let chunkRadius = 3
    let verticalChunks = 2

    init() {
        generateSpawnArea()
    }

    func generateSpawnArea() {
        for cx in -chunkRadius...chunkRadius {
            for cz in -chunkRadius...chunkRadius {
                for cy in 0..<verticalChunks {
                    let coord = ChunkCoord(x: cx, y: cy, z: cz)
                    let chunk = Chunk(coord: coord)
                    generateTerrain(into: chunk)
                    chunks[coord] = chunk
                }
            }
        }
    }

    func generateTerrain(into chunk: Chunk) {
        let baseX = chunk.coord.x * Chunk.size
        let baseY = chunk.coord.y * Chunk.size
        let baseZ = chunk.coord.z * Chunk.size

        for z in 0..<Chunk.size {
            for x in 0..<Chunk.size {
                let worldX = baseX + x
                let worldZ = baseZ + z
                let height = terrainHeight(x: worldX, z: worldZ)

                for y in 0..<Chunk.size {
                    let worldY = baseY + y
                    let block: BlockType
                    if worldY > height {
                        block = .air
                    } else if worldY == height {
                        block = .grass
                    } else if worldY > height - 3 {
                        block = .dirt
                    } else {
                        block = .stone
                    }
                    chunk.set(x, y, z, block)
                }
            }
        }
        chunk.needsRemesh = true
    }

    func terrainHeight(x: Int, z: Int) -> Int {
        let xf = Float(x) * 0.08
        let zf = Float(z) * 0.08
        let hills = sinf(xf) * 2.8 + cosf(zf * 0.75) * 2.4
        let ripple = sinf((xf + zf) * 0.7) * 1.6
        return 10 + Int(round(hills + ripple))
    }

    func chunkCoord(for worldX: Int, _ worldY: Int, _ worldZ: Int) -> ChunkCoord {
        ChunkCoord(
            x: floorDiv(worldX, Chunk.size),
            y: floorDiv(worldY, Chunk.size),
            z: floorDiv(worldZ, Chunk.size)
        )
    }

    func localCoord(_ value: Int) -> Int {
        positiveMod(value, Chunk.size)
    }

    func getBlock(worldX: Int, worldY: Int, worldZ: Int) -> BlockType {
        let cc = chunkCoord(for: worldX, worldY, worldZ)
        guard let chunk = chunks[cc] else { return .air }
        return chunk.get(localCoord(worldX), localCoord(worldY), localCoord(worldZ))
    }

    func setBlock(worldX: Int, worldY: Int, worldZ: Int, to block: BlockType) {
        let cc = chunkCoord(for: worldX, worldY, worldZ)
        guard let chunk = chunks[cc] else { return }
        let lx = localCoord(worldX)
        let ly = localCoord(worldY)
        let lz = localCoord(worldZ)
        chunk.set(lx, ly, lz, block)
        markNeighborsForRemeshIfNeeded(localX: lx, localY: ly, localZ: lz, in: cc)
    }

    private func markNeighborsForRemeshIfNeeded(localX: Int, localY: Int, localZ: Int, in coord: ChunkCoord) {
        let edges: [(Bool, ChunkCoord)] = [
            (localX == 0, ChunkCoord(x: coord.x - 1, y: coord.y, z: coord.z)),
            (localX == Chunk.size - 1, ChunkCoord(x: coord.x + 1, y: coord.y, z: coord.z)),
            (localY == 0, ChunkCoord(x: coord.x, y: coord.y - 1, z: coord.z)),
            (localY == Chunk.size - 1, ChunkCoord(x: coord.x, y: coord.y + 1, z: coord.z)),
            (localZ == 0, ChunkCoord(x: coord.x, y: coord.y, z: coord.z - 1)),
            (localZ == Chunk.size - 1, ChunkCoord(x: coord.x, y: coord.y, z: coord.z + 1))
        ]

        for (shouldTouch, neighborCoord) in edges where shouldTouch {
            chunks[neighborCoord]?.needsRemesh = true
        }
    }

    func hitTest(from origin: SIMD3<Float>, direction: SIMD3<Float>, maxDistance: Float = 8) -> HitResult? {
        let step: Float = 0.05
        var distance: Float = 0
        var previous = SIMD3<Int>(Int(floor(origin.x)), Int(floor(origin.y)), Int(floor(origin.z)))

        while distance <= maxDistance {
            let point = origin + direction * distance
            let current = SIMD3<Int>(Int(floor(point.x)), Int(floor(point.y)), Int(floor(point.z)))
            let block = getBlock(worldX: current.x, worldY: current.y, worldZ: current.z)
            if block.isSolid {
                return HitResult(block: current, place: previous, type: block)
            }
            previous = current
            distance += step
        }
        return nil
    }
}

struct HitResult {
    let block: SIMD3<Int>
    let place: SIMD3<Int>
    let type: BlockType
}
