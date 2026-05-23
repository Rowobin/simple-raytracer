[format("rgba8")]
layout(binding=0, set=1) RWTexture2D<float4> OutImage;

struct Ray{
  float3 origin;
  float3 dir;
};

struct ComputeUniform{
  int wWidth;
  int wHeight;
};
layout(binding=0, set=2) ConstantBuffer<ComputeUniform> computeUniform;

bool hit_sphere(float3 center, float radius, Ray ray){
  float3 oc = center - ray.origin;
  float a = dot(ray.dir, ray.dir);
  float b = -2.0f * dot(ray.dir, oc);
  float c = dot(oc, oc) - radius * radius;
  float discriminant = b*b - 4*a*c;
  return discriminant >= 0;
}

float4 ray_color(Ray ray){
  if(hit_sphere(float3(0.0f, 0.0f, -1.0f), 0.5f, ray)){
    return float4(1.0f, 0.0f, 0.0f, 1.0f);
  }

  float a = 0.5f * (normalize(ray.dir).y + 1.0f);
  return (1.0f-a) * float4(1.0f, 1.0f, 1.0f, 1.0f) + a * float4(0.5f, 0.7f, 1.0f, 1.0f);
}

[shader("compute")]
[numthreads(8,8,1)]
void computeMain(uint3 dispatchThreadID : SV_DispatchThreadID){
  float aspect_ratio = (float) computeUniform.wWidth / (float) computeUniform.wHeight;

  float viewport_height = 2.0f;
  float viewport_width = viewport_height * aspect_ratio;

  float3 camera_center = float3(0.0f, 0.0f, 0.0f);
  float focal_length = 1.0f;

  float3 viewport_u = float3(viewport_width, 0.0f, 0.0f);
  float3 viewport_v = float3(0.0f, -viewport_height, 0.0f);

  float3 pixel_u = viewport_u / computeUniform.wWidth;
  float3 pixel_v = viewport_v / computeUniform.wHeight;

  float3 loc_00 = camera_center - float3(0.0f, 0.0f, focal_length) - viewport_u / 2.0f - viewport_v / 2.0f
              + pixel_u / 2.0f + pixel_v / 2.0f;

  float3 pixel_center = loc_00 + dispatchThreadID.x * pixel_u + dispatchThreadID.y * pixel_v;
  float3 ray_direction = camera_center - pixel_center;

  Ray ray = {camera_center, ray_direction};

  OutImage[int2(dispatchThreadID.xy)] = ray_color(ray);
}
