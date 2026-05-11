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

  fragmentOutput.color = fragmentInput.color;

  return fragmentOutput;
}
