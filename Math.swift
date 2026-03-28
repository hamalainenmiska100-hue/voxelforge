import Foundation
import simd

extension float4x4 {
    init(translation: SIMD3<Float>) {
        self = matrix_identity_float4x4
        columns.3 = SIMD4<Float>(translation.x, translation.y, translation.z, 1)
    }

    static func rotation(yaw: Float, pitch: Float) -> float4x4 {
        let yawMatrix = float4x4(SIMD4<Float>(cos(yaw), 0, -sin(yaw), 0),
                                 SIMD4<Float>(0, 1, 0, 0),
                                 SIMD4<Float>(sin(yaw), 0, cos(yaw), 0),
                                 SIMD4<Float>(0, 0, 0, 1))

        let pitchMatrix = float4x4(SIMD4<Float>(1, 0, 0, 0),
                                   SIMD4<Float>(0, cos(pitch), sin(pitch), 0),
                                   SIMD4<Float>(0, -sin(pitch), cos(pitch), 0),
                                   SIMD4<Float>(0, 0, 0, 1))

        return yawMatrix * pitchMatrix
    }

    static func perspective(fovY: Float, aspect: Float, near: Float, far: Float) -> float4x4 {
        let y = 1 / tan(fovY * 0.5)
        let x = y / aspect
        let z = far / (near - far)
        return float4x4(
            SIMD4<Float>(x, 0, 0, 0),
            SIMD4<Float>(0, y, 0, 0),
            SIMD4<Float>(0, 0, z, -1),
            SIMD4<Float>(0, 0, z * near, 0)
        )
    }
}

extension SIMD3 where Scalar == Float {
    var normalizedSafe: SIMD3<Float> {
        let len = simd_length(self)
        return len > 0.0001 ? self / len : SIMD3<Float>(0, 0, 0)
    }
}
