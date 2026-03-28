import Foundation
import simd

struct VoxelVertex {
    var position: SIMD3<Float>
    var uv: SIMD2<Float>
}

struct ChunkMesh {
    var vertices: [VoxelVertex]
    var indices: [UInt32]
}
