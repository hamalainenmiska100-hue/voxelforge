import Foundation
import simd

enum ChunkMesher {
    static let tileCountPerRow = 2
    static let tileSize: Float = 1.0 / Float(tileCountPerRow)

    static func buildMesh(for chunk: Chunk, in world: World) -> ChunkMesh {
        var vertices: [VoxelVertex] = []
        var indices: [UInt32] = []
        var nextIndex: UInt32 = 0

        let baseX = chunk.coord.x * Chunk.size
        let baseY = chunk.coord.y * Chunk.size
        let baseZ = chunk.coord.z * Chunk.size

        for z in 0..<Chunk.size {
            for y in 0..<Chunk.size {
                for x in 0..<Chunk.size {
                    let block = chunk.get(x, y, z)
                    guard block.isSolid else { continue }

                    let worldX = baseX + x
                    let worldY = baseY + y
                    let worldZ = baseZ + z
                    let min = SIMD3<Float>(Float(worldX), Float(worldY), Float(worldZ))

                    for face in BlockFace.allCases {
                        let neighborOffset = neighborDelta(for: face)
                        let neighbor = world.getBlock(
                            worldX: worldX + neighborOffset.x,
                            worldY: worldY + neighborOffset.y,
                            worldZ: worldZ + neighborOffset.z
                        )

                        guard !neighbor.isSolid else { continue }

                        let quad = faceVertices(for: face, at: min)
                        let uv = tileUV(tileIndex: block.atlasTileIndex(for: face))

                        vertices.append(contentsOf: [
                            VoxelVertex(position: quad.0, uv: SIMD2<Float>(uv.min.x, uv.max.y)),
                            VoxelVertex(position: quad.1, uv: SIMD2<Float>(uv.max.x, uv.max.y)),
                            VoxelVertex(position: quad.2, uv: SIMD2<Float>(uv.max.x, uv.min.y)),
                            VoxelVertex(position: quad.3, uv: SIMD2<Float>(uv.min.x, uv.min.y))
                        ])

                        indices.append(contentsOf: [
                            nextIndex, nextIndex + 1, nextIndex + 2,
                            nextIndex, nextIndex + 2, nextIndex + 3
                        ])
                        nextIndex += 4
                    }
                }
            }
        }

        return ChunkMesh(vertices: vertices, indices: indices)
    }

    static func neighborDelta(for face: BlockFace) -> SIMD3<Int> {
        switch face {
        case .top: return SIMD3(0, 1, 0)
        case .bottom: return SIMD3(0, -1, 0)
        case .left: return SIMD3(-1, 0, 0)
        case .right: return SIMD3(1, 0, 0)
        case .front: return SIMD3(0, 0, 1)
        case .back: return SIMD3(0, 0, -1)
        }
    }

    static func tileUV(tileIndex: Int) -> (min: SIMD2<Float>, max: SIMD2<Float>) {
        let x = tileIndex % tileCountPerRow
        let y = tileIndex / tileCountPerRow
        let min = SIMD2<Float>(Float(x) * tileSize, Float(y) * tileSize)
        let max = min + SIMD2<Float>(repeating: tileSize)
        return (min, max)
    }

    static func faceVertices(for face: BlockFace, at min: SIMD3<Float>) -> (SIMD3<Float>, SIMD3<Float>, SIMD3<Float>, SIMD3<Float>) {
        let max = min + SIMD3<Float>(repeating: 1)
        switch face {
        case .top:
            return (
                SIMD3(min.x, max.y, min.z),
                SIMD3(max.x, max.y, min.z),
                SIMD3(max.x, max.y, max.z),
                SIMD3(min.x, max.y, max.z)
            )
        case .bottom:
            return (
                SIMD3(min.x, min.y, max.z),
                SIMD3(max.x, min.y, max.z),
                SIMD3(max.x, min.y, min.z),
                SIMD3(min.x, min.y, min.z)
            )
        case .left:
            return (
                SIMD3(min.x, min.y, min.z),
                SIMD3(min.x, min.y, max.z),
                SIMD3(min.x, max.y, max.z),
                SIMD3(min.x, max.y, min.z)
            )
        case .right:
            return (
                SIMD3(max.x, min.y, max.z),
                SIMD3(max.x, min.y, min.z),
                SIMD3(max.x, max.y, min.z),
                SIMD3(max.x, max.y, max.z)
            )
        case .front:
            return (
                SIMD3(min.x, min.y, max.z),
                SIMD3(max.x, min.y, max.z),
                SIMD3(max.x, max.y, max.z),
                SIMD3(min.x, max.y, max.z)
            )
        case .back:
            return (
                SIMD3(max.x, min.y, min.z),
                SIMD3(min.x, min.y, min.z),
                SIMD3(min.x, max.y, min.z),
                SIMD3(max.x, max.y, min.z)
            )
        }
    }
}
