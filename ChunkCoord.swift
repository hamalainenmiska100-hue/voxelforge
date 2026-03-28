import Foundation

struct ChunkCoord: Hashable {
    let x: Int
    let y: Int
    let z: Int
}

@inline(__always)
func floorDiv(_ a: Int, _ b: Int) -> Int {
    let q = a / b
    let r = a % b
    return r >= 0 ? q : q - 1
}

@inline(__always)
func positiveMod(_ value: Int, _ divisor: Int) -> Int {
    let r = value % divisor
    return r >= 0 ? r : r + divisor
}
