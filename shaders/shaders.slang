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

bool hitSphere(Ray ray, Sphere sphere, float t_min, float t_max, out HitInfo info){
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

float4 ray_color(Ray ray, Sphere[] world, int world_size){
  Sphere s1 = {float3(0.0f, 0.0f, -1.0f), 0.5f};
  HitInfo info;
  HitInfo temp_info;
  float t_min = 0.0f;
  float t_max = 1000.0f;
  float closest = t_max;
  bool hit_anything = false;

  for(int i = 0; i < world_size; i++){
    if (hitSphere(ray, world[i], t_min, closest, temp_info)){
      info = temp_info;
      closest = info.t;
      hit_anything = true;
    }
  }

  if(hit_anything){
    return 0.5 * (float4(info.normal, 0.0f) + float4(1.0f, 1.0f, 1.0f, 2.0f));
  }

  float3 unit_vector = normalize(ray.dir);
  float a = 0.5f * (unit_vector.y + 1.0f);
  return (1.0f-a) * float4(1.0f, 1.0f, 1.0f, 1.0f) + a * float4(0.5f, 0.7f, 1.0f, 1.0f);
}

[shader("compute")]
[numthreads(8,8,1)]
void computeMain(uint3 dispatchThreadID : SV_DispatchThreadID){
  float aspect_ratio = (float) computeUniform.w_width / (float) computeUniform.w_height;

  float viewport_height = 2.0f;
  float viewport_width = viewport_height * aspect_ratio;

  float3 camera_center = float3(0.0f, 0.0f, 0.0f);
  float focal_length = 1.0f;

  float3 viewport_u = float3(viewport_width, 0.0f, 0.0f);
  float3 viewport_v = float3(0.0f, -viewport_height, 0.0f);

  float3 pixel_u = viewport_u / computeUniform.w_width;
  float3 pixel_v = viewport_v / computeUniform.w_height;

  float3 loc_00 = camera_center - float3(0.0f, 0.0f, focal_length) - viewport_u / 2.0f - viewport_v / 2.0f
              + pixel_u / 2.0f + pixel_v / 2.0f;

  float3 pixel_center = loc_00 + dispatchThreadID.x * pixel_u + dispatchThreadID.y * pixel_v;
  float3 ray_direction = pixel_center - camera_center;

  const int world_size = 2;
  Sphere world[world_size];
  world[0] = {float3(0.0f, 0.0f, -1.0f), 0.5f};
  world[1] = {float3(0.0f, -100.5f, -1.0f), 100.0f};

  Ray ray = {camera_center, ray_direction};

  OutImage[int2(dispatchThreadID.xy)] = ray_color(ray, world, world_size);
}
