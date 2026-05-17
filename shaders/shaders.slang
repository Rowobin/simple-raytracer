[format("rgba8")]
layout(binding=0, set=1) RWTexture2D<float4> OutImage;

struct ComputeUniform{
  int wWidth;
  int wHeight;
};
layout(binding=0, set=2) ConstantBuffer<ComputeUniform> computeUniform;

[shader("compute")]
[numthreads(8,8,1)]
void computeMain(uint3 dispatchThreadID : SV_DispatchThreadID){
  float u = (float) dispatchThreadID.x / computeUniform.wWidth;
  if(u > 0.75f){
    OutImage[int2(dispatchThreadID.xy)] = float4(1.0f, 0.0f, 0.0f, 1.0f);
  } else if (u > 0.50f){
    OutImage[int2(dispatchThreadID.xy)] = float4(0.0f, 1.0f, 0.0f, 1.0f);
  } else if (u > 0.25f){
    OutImage[int2(dispatchThreadID.xy)] = float4(0.0f, 0.0f, 1.0f, 1.0f);
  } else {
    OutImage[int2(dispatchThreadID.xy)] = float4(0.0f, 0.0f, 0.0f, 1.0f);
  }
}
