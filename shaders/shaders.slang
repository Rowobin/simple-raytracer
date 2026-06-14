[format("rgba8")]
layout(binding = 0, set = 1) RWTexture2D<float4> out_image;

struct UniformData{
  float r_seed;
  int img_width;
  int img_height;
  float aspect_ratio;

  float3 camera_position;
  float3 camera_look_at;
  float3 up;
  float focal_length;
  int samples_per_pixel;
  
  float3 u;
  float3 v;
  float3 w;

  float3 viewport_u;
  float3 viewport_v;
  float3 pixel_u;
  float3 pixel_v;
  float3 pixel00;

  int sphere_count; 
};
layout(binding = 0, set = 2) ConstantBuffer<UniformData> u_data;

struct Sphere{
  float3 center;
  float radius;
}
layout(binding = 0, set = 0) StructuredBuffer<Sphere> spheres;

struct Ray{
  float3 origin;
  float3 direction;
};

float rand(float seed) {
    return frac(sin(seed * 12.98 + 78.23) * 43.54);
}

bool hit_sphere(Sphere sphere, Ray ray){
  float3 oc = sphere.center - ray.origin;
  float a = dot(ray.direction, ray.direction);
  float b = -2.0f * dot(ray.direction, oc);
  float c = dot(oc, oc) - sphere.radius * sphere.radius;
  float discriminant = b*b - 4 * a * c;
  return discriminant >= 0;
}

float4 ray_color(Ray ray){
  float3 norm = normalize(ray.direction);

  for(int i = 0; i < u_data.sphere_count; i++){
    Sphere s = spheres[i];
    if(hit_sphere(s, ray)){
      return float4(1.0f, 0.0f, 0.0f, 1.0f);
    } 
  }

  float a = 0.5f * (norm.y + 1.0f);
  return (1.0-a) * float4(1.0f, 1.0f, 1.0f, 1.0f) + a * float4(0.5f, 0.7f, 1.0f, 1.0f); 
}

[shader("compute")]
[numthreads(8,8,1)]
void computeMain(uint3 thread_id: SV_DispatchThreadID){
  float4 color = float4(0.0f, 0.0f, 0.0f, 0.0f);
  for(int i = 0; i < u_data.samples_per_pixel; i++){
    float x = (float) thread_id.x + (rand(u_data.r_seed + 0.967 * i * 2.188f + thread_id.x * 0.003f) - 0.5f);
    float y = (float) thread_id.y + (rand(u_data.r_seed + 0.967 * i * 2.118f + thread_id.y + 0.174f) - 0.5f);
    float3 pixel_center = u_data.pixel00 + x * u_data.pixel_u + y * u_data.pixel_v;
    Ray ray = {u_data.camera_position, pixel_center - u_data.camera_position};
    color += ray_color(ray);
  }
  color /= (float) u_data.samples_per_pixel;
  out_image[int2(thread_id.xy)] = color;
}

