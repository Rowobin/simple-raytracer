struct VertexInput{
  [vk::location(0)] float3 position;
  [vk::location(1)] float4 color;
};

struct VertexOutput{
  float4 position: SV_Position;
  [vk::location(0)] float4 color;
};

struct FragmentOutput{
  float4 color: SV_Target0;
};

struct Uniforms{
  float time;
};

[[vk::binding(0)]] 
ConstantBuffer<Uniforms> uniforms;

[shader("vertex")]
VertexOutput vertexMain(VertexInput vertexInput){
  VertexOutput vertexOutput;
  
  vertexOutput.position = float4(vertexInput.position, 1.0f);
  vertexOutput.color = vertexInput.color;

  return vertexOutput;
}

[shader("fragment")]
FragmentOutput fragmentMain(VertexOutput fragmentInput){
  FragmentOutput fragmentOutput;

  float pulse = sin(uniforms.time * 2.0f) * 0.5f + 0.5f;
  fragmentOutput.color = float4(fragmentInput.color.rgb * pulse, 1.0f);

  return fragmentOutput;
}
