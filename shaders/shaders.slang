[format("rgba8")]
layout(binding = 0, set = 1) RWTexture2D<float4> out_image;

struct UniformData{
  int img_width;
  int img_height;
};
layout(binding = 0, set = 2) ConstantBuffer<UniformData> u_data; 

[shader("compute")]
[numthreads(8,8,1)]
void computeMain(uint3 thread_id: SV_DispatchThreadID){
  out_image[int2(thread_id.xy)] = float4((float)thread_id.x / u_data.img_width, (float)thread_id.y / u_data.img_height, 0.0f, 1.0f); 
}
