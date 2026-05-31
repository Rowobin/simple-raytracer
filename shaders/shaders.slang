[format("rgba8")]
layout(binding=0, set=1) RWTexture2D<float4> OutImage;

struct Ray{
  float3 origin;
  float3 dir;
};

struct Sphere{
  float3 center;
  float radius;
};

struct HitInfo{
  float t;
  float3 p;
  float3 normal;
  bool front_face;
}

struct ComputeUniform{
  int w_width;
  int w_height;
};
layout(binding=0, set=2) ConstantBuffer<ComputeUniform> computeUniform;

float gamma_correct(float c){
  if(c > 0.0f){
    return sqrt(c);
  }
  return 0.0f;
}

float rand(float seed) {
    return frac(sin(seed * 12.98 + 78.23) * 43.54);
}

float rand_min_max(float seed, float min_, float max_){
    return rand(seed) * (max_ - min_) + min_;
}

float3 rand_unit_vector(float seed){
  int n = 0;
  while(n < 50){
    float3 p = float3(rand_min_max(seed * 1.45 + n, -1.0, 1.0), rand_min_max(seed * 2.89 + n, -1.0, 1.0), rand_min_max(seed * 4.33 + n, -1.0, 1.0));
    float len = length(p);
    if(len <= 1.0){
      return normalize(p);
    }
    n++;
  }
  return float3(0.0, 0.0, 0.0); 
}

bool hit_sphere(Ray ray, Sphere sphere, float t_min, float t_max, out HitInfo info){
  float3 oc = sphere.center - ray.origin;
  float a = dot(ray.dir, ray.dir);
  float h = dot(ray.dir, oc);
  float c = dot(oc, oc) - sphere.radius * sphere.radius;
  float discriminant = h*h - a*c;

  info = { 0.0f, float3(0.0f, 0.0f, 0.0f), float3(0.0f, 0.0f, 0.0f)};

  if(discriminant < 0.0f){
    return false;
  }

  float t = (h - sqrt(discriminant)) / a;
  if(t < t_min || t_max < t){
    t = (h + sqrt(discriminant)) / a;
    if(t < t_min || t_max < t){
      return false;
    }
  }

  info.t = t;
  info.p = ray.origin + t * ray.dir;
  float3 outward_normal = (info.p - float3(sphere.center)) / sphere.radius;
  info.front_face = dot(ray.dir, outward_normal) < 0;
  info.normal = info.front_face ? outward_normal : -outward_normal;

  return true;
}

float4 ray_color(Ray ray, Sphere[] world, int world_size, float seed){
  int bounces = 0;
  float4 color = float4(1.0f, 1.0f, 1.0f, 1.0f);

  while(bounces < 50){
    HitInfo info;
    HitInfo temp_info;
    float t_min = 0.1f;
    float t_max = 1000.0f;
    float closest = t_max;
    bool hit_anything = false;

    for(int i = 0; i < world_size; i++){
      if(hit_sphere(ray, world[i], t_min, closest, temp_info)){
        info = temp_info;
        closest = info.t;
        hit_anything = true;
      }
    }

    if(hit_anything){
      float3 direction = info.normal + rand_unit_vector(seed + bounces * 4.112);
      ray = {info.p, direction};
      color *= 0.5f;
    } else {
      float3 unit_vector = normalize(ray.dir);
      float a = 0.5f * (unit_vector.y + 1.0f);
      color *= (1.0f - a) * float4(1.0f, 1.0f, 1.0f, 1.0f) + a * float4(0.5f, 0.7f, 1.0f, 1.0f); 
      break;
    }
    bounces++;
  }

  color = float4(color.rgb, 1.0f);
  return color;
}

[shader("compute")]
[numthreads(8,8,1)]
void computeMain(uint3 dispatchThreadID : SV_DispatchThreadID){
  const int world_size = 2;
  Sphere world[world_size];
  world[0] = {float3(0.0f, 0.0f, -1.0f), 0.5f};
  world[1] = {float3(0.0f, -100.5f, -1.0f), 100.0f};

  float aspect_ratio = (float) computeUniform.w_width / (float) computeUniform.w_height;

  float viewport_height = 2.0f;
  float viewport_width = viewport_height * aspect_ratio;

  float3 camera_center = float3(0.0f, 0.0f, 0.0f);
  float focal_length = 1.0f;
  int samples_per_pixel = 100;

  float3 viewport_u = float3(viewport_width, 0.0f, 0.0f);
  float3 viewport_v = float3(0.0f, -viewport_height, 0.0f);

  float3 pixel_u = viewport_u / computeUniform.w_width;
  float3 pixel_v = viewport_v / computeUniform.w_height;

  float3 loc_00 = camera_center - float3(0.0f, 0.0f, focal_length) - viewport_u / 2.0f - viewport_v / 2.0f + pixel_u / 2.0f + pixel_v / 2.0f;

  float4 color = float4(0.0f, 0.0f, 0.0f, 0.0f);
  for(int i = 0; i < samples_per_pixel; i++){
    float rand_seed = dispatchThreadID.x * 1.973f + dispatchThreadID.y * 9.27f + i * 3.69f;

    float3 offset_x = (dispatchThreadID.x + rand(rand_seed) - 0.5f) * pixel_u;
    float3 offset_y = (dispatchThreadID.y + rand(rand_seed+3.7f) -0.5f) * pixel_v;

    float3 pixel_center = loc_00 + offset_x + offset_y;
    float3 ray_direction = pixel_center - camera_center;
    Ray ray = {camera_center, ray_direction};
    
    color += ray_color(ray, world, world_size, rand_seed);
  }
  
  color /= samples_per_pixel;
  
  color.r = gamma_correct(color.r);
  color.g = gamma_correct(color.g);
  color.b = gamma_correct(color.b);
  
  color.r = clamp(color.r, 0.000, 0.999);
  color.g = clamp(color.g, 0.000, 0.999);
  color.b = clamp(color.b, 0.000, 0.999);

  OutImage[int2(dispatchThreadID.xy)] = color;
}
