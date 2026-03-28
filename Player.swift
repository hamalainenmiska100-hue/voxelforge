import Foundation
import simd

final class Player {
    var position = SIMD3<Float>(0, 16, 18)
    var yaw: Float = -.pi / 2
    var pitch: Float = -0.35
    var moveInput = SIMD2<Float>(0, 0)
    var lookInput = SIMD2<Float>(0, 0)
    var verticalVelocity: Float = 0
    var isGrounded = false

    var forward: SIMD3<Float> {
        SIMD3<Float>(cos(pitch) * cos(yaw), sin(pitch), cos(pitch) * sin(yaw)).normalizedSafe
    }

    var flatForward: SIMD3<Float> {
        SIMD3<Float>(cos(yaw), 0, sin(yaw)).normalizedSafe
    }

    var right: SIMD3<Float> {
        SIMD3<Float>(-sin(yaw), 0, cos(yaw)).normalizedSafe
    }

    func update(deltaTime: Float, world: World) {
        yaw += lookInput.x * 1.8 * deltaTime
        pitch += lookInput.y * 1.4 * deltaTime
        pitch = max(-1.45, min(1.45, pitch))

        let move = flatForward * moveInput.y + right * moveInput.x
        let speed: Float = 7.0
        position += move * speed * deltaTime

        verticalVelocity -= 22 * deltaTime
        position.y += verticalVelocity * deltaTime

        let foot = SIMD3<Int>(Int(floor(position.x)), Int(floor(position.y - 1.75)), Int(floor(position.z)))
        if world.getBlock(worldX: foot.x, worldY: foot.y, worldZ: foot.z).isSolid {
            position.y = Float(foot.y + 2)
            verticalVelocity = 0
            isGrounded = true
        } else {
            isGrounded = false
        }
    }

    func jump() {
        guard isGrounded else { return }
        verticalVelocity = 8.5
        isGrounded = false
    }
}
