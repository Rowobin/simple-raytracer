layout(binding = 0, set = 1) RWTexture2D<float4> out_image;

struct UniformData{
  int r_seed;
  int img_width;
  int img_height;
  float aspect_ratio;

  float4 camera_position;
  float4 camera_look_at;
  float4 up;
  float focal_length;
  float defocus_angle;
  float focus_dist;
  float fov;

  float viewport_h;
  float viewport_w;

  float4 viewport_u;
  float4 viewport_v;
  float4 pixel_u;
  float4 pixel_v;

  float4 u;
  float4 v;
  float4 w;

  float4 defocus_disk_u;
  float4 defocus_disk_v;

  float4 pixel00;

  int sphere_count;
  int samples_per_pixel;
  float t_min;
  float t_max;

  int max_bounces;
};
layout(binding = 0, set = 2) ConstantBuffer<UniformData> u_data; 

enum MaterialType{
  LAMBERTIAN,
  METAL,
  DIELECTRIC,
};

struct Material{
  MaterialType type;
  float4 albedo;
  float fuzz;
  float refraction_index;
};

struct Sphere{
  float4 center;
  float radius;
  Material material;
};
layout(binding = 0, set = 0) StructuredBuffer<Sphere> spheres;

struct HitInfo{
  float t;
  float3 p;
  float3 normal;
  bool front_face;
  Material mat;
};

struct Ray{
  float3 origin;
  float3 direction;
};

float rand(float seed)
{
    return frac(sin(seed * 12.98f + 78.23f) * 43879.54f);
}

float rand_range(float seed, float r_min, float r_max){
    return r_min + rand(seed) * (r_max - r_min);
}

float3 rand_vector_3(float seed){
    float3 v = float3(
      rand_range(seed * 3.49f, -1.0f, 1.0f),
      rand_range(seed * 5.01f, -1.0f, 1.0f),
      rand_range(seed * 1.88f, -1.0f, 1.0f)
    );
    for(int i = 0; i < 10; i++){
      if(length(v) <= 1.0f){
        return v;
      }
      v = float3(
        rand_range(seed * 3.49f + (i * 2.556f), -1.0f, 1.0f),
        rand_range(seed * 5.01f + (i * 2.556f),-1.0f, 1.0f),
        rand_range(seed * 1.88f + (i * 2.556f), -1.0f, 1.0f)
      );
    }
    return float3(0.0f, 0.0f, 0.0f);
}

float3 rand_vector_2(float seed){
  float3 v = float3(
    rand_range(seed * 4.39f, -1.0f, 1.0f),
    rand_range(seed * 5.01f, -1.0f, 1.0f),
    0.0f
  );
  for(int i = 0; i < 10; i++){
    if(length(v) <= 1.0f){
      return v;
    } 
    v = float3(
      rand_range(seed * 4.39f + (i * 2.556f), -1.0f, 1.0f),
      rand_range(seed * 5.01f + (i * 2.556f), -1.0f, 1.0f),
      0.0f
    );
  }
  return float3(0.0f, 0.0f, 0.0f);
}

float gamma_correct(float v){
  if(v >= 0.0f){
    return sqrt(v);
  }
  return v;
}

bool hit_sphere(Sphere sphere, Ray ray, out HitInfo info, float t_min, float t_max){
  float3 oc = sphere.center.xyz - ray.origin;
  float a = dot(ray.direction, ray.direction);
  float b = -2.0f * dot(ray.direction, oc);
  float c = dot(oc, oc) - sphere.radius * sphere.radius;
  float discriminant = b * b - 4 * a * c;
  
  info = {};

  if(discriminant <= 0.0f){
    return false;
  } 

  float t = (-b - sqrt(discriminant)) / (2 * a);
  if(t <= t_min || t_max <= t){
    t = (-b + sqrt(discriminant)) / (2 * a);
    if(t <= t_min || t_max <= t){
      return false;
    }
  }

  info.mat = sphere.material;
  info.t = t;
  info.p = ray.origin + info.t * ray.direction;
  float3 outwards_normal = (info.p - sphere.center.xyz) / sphere.radius;
  info.front_face = dot(ray.direction, outwards_normal) <= 0.0f;
  info.normal = info.front_face ? outwards_normal : - outwards_normal;

  return true;
}

float4 ray_color(Ray ray, float seed){
  float4 color = float4(1.0f, 1.0f, 1.0f, 1.0f);

  for(int bounces = 0; bounces < u_data.max_bounces; bounces++){
    HitInfo info;
    info.t = u_data.t_max;
    bool hit_anything = false;

    for(int i = 0; i < u_data.sphere_count; i++){
      HitInfo tmp;
      if(hit_sphere(spheres[i], ray, tmp, u_data.t_min, info.t)){
        info = tmp;
        hit_anything = true;
      }
    }

    if(hit_anything){
      float3 direction;
      switch (info.mat.type){
        case MaterialType.LAMBERTIAN:
          color *= float4(info.mat.albedo.xyz, 1.0f);
          direction = info.normal + rand_vector_3(seed + bounces * 7.23f);
          direction = normalize(direction);
          if(dot(info.normal, direction) <= 0.0f){
            direction = -direction;
          }
          break;
        case MaterialType.METAL:
          color *= float4(info.mat.albedo.xyz, 1.0f);
          direction = ray.direction - 2 * dot(ray.direction, info.normal) * info.normal;
          direction = normalize(direction) + info.mat.fuzz * rand_vector_3(seed + bounces * 3.11f + info.mat.fuzz * 1.23f);
          if(dot(info.normal, direction) <= 0.0f){
            direction = -direction;
          }
          break;
        case MaterialType.DIELECTRIC:
          color *= float4(1.0f, 1.0f, 1.0f, 1.0f);
          float ri = info.front_face ? (1.0 / info.mat.refraction_index) : info.mat.refraction_index;
          float3 unit_vector = normalize(ray.direction);
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
      float3 n = normalize(ray.direction);
      float a = 0.5f * (n.y + 1.0f);
      color *= (1 - a) * float4(1.0f, 1.0f, 1.0f, 1.0f) + a * float4(0.5f, 0.7f, 1.0f, 1.0f);
      break;
    }
  }
 
  return color;
}

[shader("compute")]
[numthreads(8,8,1)]
void computeMain(uint3 thread_id: SV_DispatchThreadID){
  float3 pixel00 = u_data.pixel00.xyz;
  float3 pixel_u = u_data.pixel_u.xyz;
  float3 pixel_v = u_data.pixel_v.xyz;
  float3 defocus_disk_u = u_data.defocus_disk_u.xyz;
  float3 defocus_disk_v = u_data.defocus_disk_v.xyz;

  float3 camera_position = u_data.camera_position.xyz;

  float4 color = float4(0.0f, 0.0f, 0.0f, 0.0f);
  for(int i = 0; i < u_data.samples_per_pixel; i++){
    float x = (float) thread_id.x + (rand(u_data.r_seed + i * 2.188f + thread_id.x * 1.3f + thread_id.y * 6.33f) - 0.5f);
    float y = (float) thread_id.y + (rand(u_data.r_seed + i * 3.791f + thread_id.x * 5.9f + thread_id.y * 3.17f) - 0.5f);
    float3 pixel_center = pixel00 + x * pixel_u + y * pixel_v;

    float3 ray_origin = camera_position; 
    if(u_data.defocus_angle > 0.0f){
      float3 p = rand_vector_2(u_data.r_seed + 1.922f * i + thread_id.x * 4.6f + thread_id.y * 1.23f);
      ray_origin = camera_position + p.x * defocus_disk_u + p.y * defocus_disk_v;
    }

    float3 ray_direction = pixel_center - ray_origin;

    Ray ray = {ray_origin, ray_direction};
    color += ray_color(ray, u_data.r_seed + thread_id.x * 1.21f + thread_id.y * 0.45f + i * 7.77f);
  }

  color /= (float) u_data.samples_per_pixel;

  color.r = gamma_correct(color.r); 
  color.g = gamma_correct(color.g); 
  color.b = gamma_correct(color.b); 

  color.r = clamp(color.r, 0.0f, 1.0f);
  color.g = clamp(color.g, 0.0f, 1.0f);
  color.b = clamp(color.b, 0.0f, 1.0f);

  out_image[int2(thread_id.xy)] = color;
}
