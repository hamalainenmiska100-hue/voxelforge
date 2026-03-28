#include <metal_stdlib>
using namespace metal;

struct VoxelVertex {
    float3 position;
    float2 uv;
};

struct Uniforms {
    float4x4 viewProjection;
};

struct VertexOut {
    float4 position [[position]];
    float2 uv;
};

vertex VertexOut voxelVertex(uint vid [[vertex_id]],
                             const device VoxelVertex* vertices [[buffer(0)]],
                             constant Uniforms& uniforms [[buffer(1)]]) {
    VertexOut out;
    float4 worldPosition = float4(vertices[vid].position, 1.0);
    out.position = uniforms.viewProjection * worldPosition;
    out.uv = vertices[vid].uv;
    return out;
}

fragment float4 voxelFragment(VertexOut in [[stage_in]],
                              texture2d<float> atlas [[texture(0)]],
                              sampler atlasSampler [[sampler(0)]]) {
    return atlas.sample(atlasSampler, in.uv);
}
