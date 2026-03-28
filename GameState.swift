import Foundation
import simd

@MainActor
final class GameState: ObservableObject {
    let world = World()
    let player = Player()

    func breakBlock() {
        guard let hit = world.hitTest(from: player.position, direction: player.forward) else { return }
        world.setBlock(worldX: hit.block.x, worldY: hit.block.y, worldZ: hit.block.z, to: .air)
    }

    func placeBlock() {
        guard let hit = world.hitTest(from: player.position, direction: player.forward) else { return }
        world.setBlock(worldX: hit.place.x, worldY: hit.place.y, worldZ: hit.place.z, to: .grass)
    }
}
