struct VertexInput{
  float3 position;
  float4 color;
};

struct VertexOutput{
  float4 position: SV_Position;
  float4 color;
};

struct FragmentOutput{
  float4 color: SV_Target0;
};

struct Uniforms{
  float time;
};
layout(binding=0, set=3) ConstantBuffer<Uniforms> uniforms;

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
  fragmentOutput.color = float4(pulse * fragmentInput.color.rgb, 1.0f);

  return fragmentOutput;
}
