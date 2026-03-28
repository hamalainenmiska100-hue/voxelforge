import Foundation
import MetalKit
import simd

struct Uniforms {
    var viewProjection: float4x4
}

final class Renderer: NSObject, MTKViewDelegate {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let pipelineState: MTLRenderPipelineState
    let depthState: MTLDepthStencilState
    let texture: MTLTexture
    let sampler: MTLSamplerState
    let gameState: GameState

    private var meshBuffers: [ChunkCoord: (vertex: MTLBuffer, index: MTLBuffer, count: Int)] = [:]
    private var lastFrameTime: CFTimeInterval = CACurrentMediaTime()

    init?(view: MTKView, gameState: GameState) {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else { return nil }

        self.device = device
        self.commandQueue = commandQueue
        self.gameState = gameState

        view.device = device
        view.depthStencilPixelFormat = .depth32Float
        view.colorPixelFormat = .bgra8Unorm
        view.sampleCount = 1
        view.preferredFramesPerSecond = 60
        view.clearColor = MTLClearColor(red: 0.53, green: 0.76, blue: 0.96, alpha: 1)

        let library = try! device.makeDefaultLibrary(bundle: .main)
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = library.makeFunction(name: "voxelVertex")
        descriptor.fragmentFunction = library.makeFunction(name: "voxelFragment")
        descriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        descriptor.depthAttachmentPixelFormat = view.depthStencilPixelFormat
        self.pipelineState = try! device.makeRenderPipelineState(descriptor: descriptor)

        let depthDesc = MTLDepthStencilDescriptor()
        depthDesc.isDepthWriteEnabled = true
        depthDesc.depthCompareFunction = .less
        self.depthState = device.makeDepthStencilState(descriptor: depthDesc)!

        let textureLoader = MTKTextureLoader(device: device)
        self.texture = try! textureLoader.newTexture(name: "VoxelAtlas", scaleFactor: 1.0, bundle: .main, options: [
            .SRGB: false,
            .generateMipmaps: true,
            .textureUsage: NSNumber(value: MTLTextureUsage.shaderRead.rawValue)
        ])

        let samplerDesc = MTLSamplerDescriptor()
        samplerDesc.minFilter = .nearest
        samplerDesc.magFilter = .nearest
        samplerDesc.mipFilter = .nearest
        samplerDesc.sAddressMode = .clampToEdge
        samplerDesc.tAddressMode = .clampToEdge
        self.sampler = device.makeSamplerState(descriptor: samplerDesc)!
        super.init()

        rebuildDirtyMeshes()
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

    func draw(in view: MTKView) {
        let now = CACurrentMediaTime()
        let delta = min(Float(now - lastFrameTime), 1.0 / 20.0)
        lastFrameTime = now
        gameState.player.update(deltaTime: delta, world: gameState.world)
        rebuildDirtyMeshes()

        guard let renderPassDescriptor = view.currentRenderPassDescriptor,
              let drawable = view.currentDrawable,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }

        encoder.setRenderPipelineState(pipelineState)
        encoder.setDepthStencilState(depthState)
        encoder.setFragmentTexture(texture, index: 0)
        encoder.setFragmentSamplerState(sampler, index: 0)

        let aspect = Float(view.drawableSize.width / max(1, view.drawableSize.height))
        let projection = float4x4.perspective(fovY: 70 * .pi / 180, aspect: aspect, near: 0.1, far: 400)
        let rotation = float4x4.rotation(yaw: gameState.player.yaw, pitch: gameState.player.pitch)
        let translation = float4x4(translation: -gameState.player.position)
        var uniforms = Uniforms(viewProjection: projection * rotation * translation)
        encoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 1)

        for coord in gameState.world.chunks.keys.sorted(by: sortChunks) {
            guard let buffers = meshBuffers[coord], buffers.count > 0 else { continue }
            encoder.setVertexBuffer(buffers.vertex, offset: 0, index: 0)
            encoder.drawIndexedPrimitives(type: .triangle,
                                          indexCount: buffers.count,
                                          indexType: .uint32,
                                          indexBuffer: buffers.index,
                                          indexBufferOffset: 0)
        }

        encoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    private func rebuildDirtyMeshes() {
        for (coord, chunk) in gameState.world.chunks where chunk.needsRemesh {
            let mesh = ChunkMesher.buildMesh(for: chunk, in: gameState.world)
            let vertexBuffer: MTLBuffer
            let indexBuffer: MTLBuffer
            if mesh.vertices.isEmpty {
                vertexBuffer = device.makeBuffer(length: 1)!
            } else {
                let vertexSize = mesh.vertices.count * MemoryLayout<VoxelVertex>.stride
                vertexBuffer = device.makeBuffer(bytes: mesh.vertices, length: vertexSize)!
            }
            if mesh.indices.isEmpty {
                indexBuffer = device.makeBuffer(length: 1)!
            } else {
                let indexSize = mesh.indices.count * MemoryLayout<UInt32>.stride
                indexBuffer = device.makeBuffer(bytes: mesh.indices, length: indexSize)!
            }
            meshBuffers[coord] = (vertexBuffer, indexBuffer, mesh.indices.count)
            chunk.needsRemesh = false
        }
    }

    private func sortChunks(_ a: ChunkCoord, _ b: ChunkCoord) -> Bool {
        if a.y != b.y { return a.y < b.y }
        if a.z != b.z { return a.z < b.z }
        return a.x < b.x
    }
}
