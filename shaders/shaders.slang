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

float gamma_correct(float c){
  if(c <= 0.0031308f){
    return c * 12.92f;
  }
  return 1.055f * pow(c, 1.0f / 2.4f) - 0.055f;
}

[shader("fragment")]
FragmentOutput fragmentMain(VertexOutput fragmentInput){
  FragmentOutput fragmentOutput;

  float pulse = sin(uniforms.time * 2.0f) * 0.5f + 0.5f;
  fragmentOutput.color = float4(pulse * fragmentInput.color.rgb, 1.0f);
  fragmentOutput.color.r = gamma_correct(fragmentOutput.color.r);
  fragmentOutput.color.g = gamma_correct(fragmentOutput.color.g);
  fragmentOutput.color.b = gamma_correct(fragmentOutput.color.b);

  return fragmentOutput;
}
