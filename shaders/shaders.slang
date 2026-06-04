[format("rgba8")]
layout(binding=0, set=1) RWTexture2D<float4> OutImage;

struct Ray{
  float3 origin;
  float3 dir;
};

enum MaterialType{
  LAMBERTIAN,
  METAL,
  DIELECTRIC
};

struct Material{
  MaterialType type;
  float4 albedo;
  float fuzz;
  float refraction_index;
};

struct Sphere{
  float3 center;
  float radius;
  Material mat;
};

struct HitInfo{
  float t;
  float3 p;
  float3 normal;
  bool front_face;
  Material mat;
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
  info.mat = sphere.mat;

  return true;
}

float4 ray_color(Ray ray, Sphere[] world, int world_size, float seed){
  int bounces = 0;
  float4 color = float4(1.0f, 1.0f, 1.0f, 1.0f);

  while(bounces < 20){
    HitInfo info;
    HitInfo temp_info;
    float t_min = 0.0001f;
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
      float3 direction;
      switch(info.mat.type){
        case MaterialType.LAMBERTIAN:
          direction = info.normal + rand_unit_vector(seed + bounces * 4.112);
          if(dot(direction, direction) < 0.001f){
            direction = info.normal;
          }
          if(dot(direction, info.normal) <= 0.0f){
            color *= float4(0.0f, 0.0f, 0.0f, 1.0f);
            break;
          }
          color *= info.mat.albedo; 
          break;
        case MaterialType.METAL:
          direction = ray.dir - 2 * dot(ray.dir, info.normal) * info.normal;
          direction = normalize(direction) + info.mat.fuzz * rand_unit_vector(seed + bounces * 3.111 + info.mat.fuzz * 1.224);
          if(dot(direction, info.normal) <= 0.0f){
            color *= float4(0.0f, 0.0f, 0.0f, 1.0f);
            break;
          }
          color *= info.mat.albedo; 
          break;
        case MaterialType.DIELECTRIC:
          color *= float4(1.0f, 1.0f, 1.0f, 1.0f);
          float ri = info.front_face ? (1.0 / info.mat.refraction_index) : info.mat.refraction_index;
          float3 unit_vector = normalize(ray.dir);
          float cos_theta = min(dot(-unit_vector, info.normal), 1.0f);
          float sin_theta = sqrt(1.0 - cos_theta * cos_theta);
          
          float r0 = (1 - ri) / (1 + ri);
          r0 = r0 * r0;
          r0 = r0 + (1 - r0) * pow(1 - cos_theta, 5); 
          
          if(sin_theta * ri > 1.0f || r0 > rand(seed + bounces * 3.21)){
            direction = unit_vector - 2 * dot(unit_vector, info.normal) * info.normal;
          } else {
            float3 r_out_perp = ri * (unit_vector + cos_theta * info.normal);
            float3 r_out_parallel = -sqrt(abs(1.0 - length(r_out_perp) * length(r_out_perp))) * info.normal;
            direction = r_out_perp + r_out_parallel;
          }
          break; 
      }
      ray = {info.p, direction};
    } else {
      float3 unit_vector = normalize(ray.dir);
      float a = 0.5f * (unit_vector.y + 1.0f);
      color *= (1.0f - a) * float4(1.0f, 1.0f, 1.0f, 1.0f) + a * float4(0.5f, 0.7f, 1.0f, 1.0f); 
      break;
    }
    bounces++;
  }

  return color;
}

[shader("compute")]
[numthreads(32,32,1)]
void computeMain(uint3 dispatchThreadID : SV_DispatchThreadID){
  const int world_size = 5;

  Material material_ground = {MaterialType.LAMBERTIAN, float4(0.8, 0.8, 0.0, 1.0), 0.0, 0.0};
  Material material_right = {MaterialType.METAL, float4(0.8, 0.6, 0.2, 1.0), 0.4, 0.0};
  Material material_center = {MaterialType.LAMBERTIAN, float4(0.1, 0.2, 0.5, 1.0), 0.0, 0.0};
  Material material_left = {MaterialType.DIELECTRIC, float4(0.0, 0.0, 0.0, 0.0), 0.0, 1.50};
  Material material_bubble = {MaterialType.DIELECTRIC, float4(0.0, 0.0, 0.0, 0.0), 0.0, 1.00 / 1.50};

  Sphere world[world_size];
  world[0] = {float3(0.0f, -100.5f, -1.0f), 100.0f, material_ground};
  world[1] = {float3(0.0f, 0.0f, -1.2f), 0.5f, material_center};
  world[2] = {float3(-1.0f, 0.0f, -1.0f), 0.5f, material_left};
  world[3] = {float3(-1.0f, 0.0f, -1.0f), 0.4f, material_bubble};
  world[4] = {float3(1.0f, 0.0f, -1.0f), 0.5f, material_right};

  float aspect_ratio = (float) computeUniform.w_width / (float) computeUniform.w_height;
  float vfov = 45.0f;
  float3 look_from = float3(-2.0, 2.0, 2.0);
  float3 look_at = float3(0.0, 0.0, -1.0);
  float3 vec_up = float3(0.0, 1.0, 0.0);

  float3 camera_center = look_from;
  float focal_length = length(look_from - look_at);
  float theta = radians(vfov);
  float h = tan(theta/2);
  float viewport_height = 2.0f * h * focal_length;
  float viewport_width = viewport_height * aspect_ratio;

  float3 w = normalize(look_from - look_at);
  float3 u = normalize(cross(vec_up, w));
  float3 v = cross(w, u);

  int samples_per_pixel = 100;

  float3 viewport_u = viewport_width * u;
  float3 viewport_v = -viewport_height * v;

  float3 pixel_u = viewport_u / computeUniform.w_width;
  float3 pixel_v = viewport_v / computeUniform.w_height;

  float3 loc_00 = camera_center - focal_length * w - viewport_u / 2.0f - viewport_v / 2.0f + pixel_u / 2.0f + pixel_v / 2.0f;

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

