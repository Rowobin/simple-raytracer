#include <iostream>
#include <vector>
#include <ctime>
#include <cstdlib>
#include <cstring>
#include <algorithm>

#define SDL_MAIN_USE_CALLBACKS
#include <SDL3/SDL.h>
#include <SDL3/SDL_main.h>

#include "imgui.h"
#include "imgui_impl_sdl3.h"
#include "imgui_impl_sdlgpu3.h"

#include "glm/glm.hpp"
#include "glm/gtc/type_ptr.hpp"

struct BoundingBox{
  glm::vec4 x;
  glm::vec4 y;
  glm::vec4 z;
};

struct BVHNode{
  BoundingBox bbox;
  int left;
  int right;
  int count;
  float pad;
};

enum MaterialType{
  LAMBERTIAN,
  METAL,
  DIELECTRIC
};

struct Material{
  MaterialType Type;
  float pad1[3];

  glm::vec4 albedo;
  float fuzz;
  float refraction_index;
  float pad2[2];
};

struct Sphere{
  glm::vec4 center;
  float radius;
  float pad[3];
  Material material;
};

struct UniformData{
  int r_seed;
  int img_width;
  int img_height;
  float aspect_ratio;

  glm::vec4 camera_position;
  glm::vec4 camera_look_at;
  glm::vec4 up;
  float defocus_angle;
  float focus_dist;
  float fov;
  
  float viewport_h;
  float viewport_w;
  float pad2[3];
  
  glm::vec4 viewport_u;
  glm::vec4 viewport_v;
  glm::vec4 pixel_u;
  glm::vec4 pixel_v;

  glm::vec4 u;
  glm::vec4 v;
  glm::vec4 w;

  glm::vec4 defocus_disk_u;
  glm::vec4 defocus_disk_v;

  glm::vec4 pixel00;

  int sphere_count;
  int samples_per_pixel;
  float t_min;
  float t_max;

  int max_bounces;
  int bvh_node_count;
  int use_bvh;
  float pad3;
};

struct Context{
  std::string base_path;

  SDL_Window* window;
  SDL_GPUDevice* device;
  
  SDL_GPUComputePipeline* compute_pipeline;
  SDL_GPUTexture* compute_render_texture;
  UniformData u_data;
  SDL_GPUBuffer* compute_sphere_buffer;
  SDL_GPUBuffer* compute_bvh_buffer;

  Uint64 frame_counter;
  Uint64 last_fps_update;
  Uint64 frame_rate;
};
Context context;

bool sphere_sort_x(std::pair<int, Sphere> a, std::pair<int, Sphere> b){
  return a.second.center.x < b.second.center.x;
}

bool sphere_sort_y(std::pair<int, Sphere> a, std::pair<int, Sphere> b){
  return a.second.center.y < b.second.center.y;
}

bool sphere_sort_z(std::pair<int, Sphere> a, std::pair<int, Sphere> b){
  return a.second.center.z < b.second.center.z;
}

int createBVHRecursive(std::vector<BVHNode>& bvh_list, std::vector<std::pair<int, Sphere>>& spheres, int start, int end){
  BVHNode bvh_node;
  bvh_node.left = -1;
  bvh_node.right = -1;
  BoundingBox bbox = {
    {std::numeric_limits<float>::infinity(), -std::numeric_limits<float>::infinity(), 0.0f, 0.0f},
    {std::numeric_limits<float>::infinity(), -std::numeric_limits<float>::infinity(), 0.0f, 0.0f},
    {std::numeric_limits<float>::infinity(), -std::numeric_limits<float>::infinity(), 0.0f, 0.0f},
  };

  for(int i = start; i < end; i++){
    Sphere sphere = spheres[i].second;

    BoundingBox bbox_sphere;
    bbox_sphere.x = { sphere.center.x - sphere.radius, sphere.center.x + sphere.radius, 0.0f, 0.0f};
    bbox_sphere.y = { sphere.center.y - sphere.radius, sphere.center.y + sphere.radius, 0.0f, 0.0f};
    bbox_sphere.z = { sphere.center.z - sphere.radius, sphere.center.z + sphere.radius, 0.0f, 0.0f};

    bbox.x = {glm::min(bbox.x[0], bbox_sphere.x[0]), glm::max(bbox.x[1], bbox_sphere.x[1]), 0.0f, 0.0f};
    bbox.y = {glm::min(bbox.y[0], bbox_sphere.y[0]), glm::max(bbox.y[1], bbox_sphere.y[1]), 0.0f, 0.0f};
    bbox.z = {glm::min(bbox.z[0], bbox_sphere.z[0]), glm::max(bbox.z[1], bbox_sphere.z[1]), 0.0f, 0.0f};
  }

  if(end - start == 1){
    bvh_node.left = spheres[start].first; 
  } else {
    float x_length = bbox.x[1] - bbox.x[0];
    float y_length = bbox.y[1] - bbox.y[0];
    float z_length = bbox.z[1] - bbox.z[0];

    if(x_length >= y_length && x_length >= z_length){
      std::sort(spheres.begin() + start, spheres.begin() + end, sphere_sort_x); 
    } else if (y_length >= z_length){
      std::sort(spheres.begin() + start, spheres.begin() + end, sphere_sort_y); 
    } else {
      std::sort(spheres.begin() + start, spheres.begin() + end, sphere_sort_z); 
    }

    int half = (end - start) / 2;
    bvh_node.left = createBVHRecursive(bvh_list, spheres, start, start + half);
    bvh_node.right = createBVHRecursive(bvh_list, spheres, start + half, end);
  }

  bvh_node.bbox = bbox;
  bvh_node.count = end - start;
  bvh_list.push_back(bvh_node);
  return bvh_list.size() - 1;
}

void createBVH(std::vector<BVHNode>& bvh_list, std::vector<Sphere>& spheres){
  std::vector<std::pair<int, Sphere>> sphere_pairs;
  sphere_pairs.reserve(spheres.size());

  for(int i = 0; i < spheres.size(); i++){
    sphere_pairs.push_back(std::pair<int, Sphere>(i, spheres[i]));
  }

  bvh_list.clear();
  bvh_list.reserve(spheres.size() * 2);

  createBVHRecursive(bvh_list, sphere_pairs, 0, spheres.size());
}

int transferDataToGPU(void* cpu_data, Uint32 data_size, SDL_GPUBuffer** gpu_buffer){
  SDL_GPUBufferCreateInfo buffer_info = {
    .usage = SDL_GPU_BUFFERUSAGE_COMPUTE_STORAGE_READ,
    .size = data_size,
  };

  *gpu_buffer = SDL_CreateGPUBuffer(context.device, &buffer_info);
  if(!gpu_buffer){
    std::cerr << "SDL_CreateGPUBuffer ERROR - " << SDL_GetError() << std::endl;
    return -1;
  }

  SDL_GPUTransferBufferCreateInfo transfer_info = {
    .usage = SDL_GPU_TRANSFERBUFFERUSAGE_UPLOAD,
    .size = data_size 
  };
  SDL_GPUTransferBuffer* transfer_buffer = SDL_CreateGPUTransferBuffer(context.device, &transfer_info);
  if(!transfer_buffer){
    std::cerr << "SDL_CreateGPUTransferBuffer ERROR - " << SDL_GetError() << std::endl;
    return -1;
  }

  void* map = SDL_MapGPUTransferBuffer(context.device, transfer_buffer, false);
  memcpy(map, cpu_data, data_size);
  SDL_UnmapGPUTransferBuffer(context.device, transfer_buffer);

  SDL_GPUCommandBuffer* command_buffer = SDL_AcquireGPUCommandBuffer(context.device);

  SDL_GPUTransferBufferLocation transfer_location = {.transfer_buffer = transfer_buffer, .offset = 0};
  SDL_GPUBufferRegion buffer_region = {.buffer = *gpu_buffer, .offset = 0, .size = data_size};
  SDL_GPUCopyPass* copy_pass = SDL_BeginGPUCopyPass(command_buffer);
  SDL_UploadToGPUBuffer(copy_pass, &transfer_location, &buffer_region, false);
  SDL_EndGPUCopyPass(copy_pass);

  SDL_SubmitGPUCommandBuffer(command_buffer);

  SDL_ReleaseGPUTransferBuffer(context.device, transfer_buffer);

  return 0;
}

int contextInit(){
  context.window = SDL_CreateWindow("Simple Raytracer", 800, 450, 0);
  if(!context.window){
    std::cerr << "SDL_CreateWindow ERROR - " << SDL_GetError() << std::endl;
    return -1;
  }

  context.device = SDL_CreateGPUDevice(
#ifdef __APPLE__
    SDL_GPU_SHADERFORMAT_MSL,
#else
    SDL_GPU_SHADERFORMAT_SPIRV,
#endif
    false,
    NULL
  );
  if(!context.device){
    std::cerr << "SDL_CreateGPUDevice ERROR - " << SDL_GetError() << std::endl;
    return -1;
 }
  SDL_ClaimWindowForGPUDevice(context.device, context.window);

  context.base_path = std::string(SDL_GetBasePath());
  context.frame_counter = 0;
  context.last_fps_update = 0;
  context.frame_rate = 0;

  context.u_data.camera_position = {5.0f, 5.0f, 5.0f, 0.0f};
  context.u_data.camera_look_at = {0.0f, 0.0f, -1.0f, 0.0f};
  context.u_data.up = {0.0f, 1.0f, 0.0f, 0.0f};
  context.u_data.defocus_angle = 0.0f;
  context.u_data.focus_dist = 2.0f;
  context.u_data.fov = 75.0f;
  context.u_data.samples_per_pixel = 4;
  context.u_data.t_min = 0.0001f;
  context.u_data.t_max = 100.0f;
  context.u_data.max_bounces = 8;
  context.u_data.use_bvh = 1;

  Material materials[] = {
      { LAMBERTIAN, {}, {0.8f, 0.0f, 0.0f, 0.0f}, 0.0f, 0.0f, {} },      // red_lambert
      { LAMBERTIAN, {}, {0.0f, 0.0f, 0.8f, 0.0f}, 0.0f, 0.0f, {} },      // blue_lambert
      { LAMBERTIAN, {}, {0.0f, 0.3f, 0.0f, 0.0f}, 0.0f, 0.0f, {} },      // green_lambert 
      { METAL,      {}, {0.9f, 0.9f, 0.9f, 0.0f}, 0.0f, 0.0f, {} },      // white_metal
      { METAL,      {}, {0.1f, 0.1f, 0.7f, 0.0f}, 0.2f, 0.0f, {} },      // blue metal
      { DIELECTRIC, {}, {1.0f, 1.0f, 1.0f, 0.0f}, 0.0f, 1.0f / 1.5f, {} }, // glass
  };
  Material floor = { LAMBERTIAN, {}, {0.2f, 0.6f, 0.1f, 0.0f}, 0.0f, 0.0f, {} };

  std::vector<Sphere> spheres;
  spheres.push_back({ {0.0f, -800.5f, 0.0f, 0.0f}, 800.0f, {}, floor });
  for(int i = 1; i < 500; i++){
    Sphere s;
    s.radius = 0.5f;
    s.center = {std::rand() % 100 - 50.0f, s.radius - 0.5f, std::rand() % 100 - 50.0f, 0.0f};
    s.material = materials[i % 6];
    spheres.push_back(s);
  }
  context.u_data.sphere_count = spheres.size();

  std::vector<BVHNode> bvh;
  createBVH(bvh, spheres);
  context.u_data.bvh_node_count = bvh.size();

  if(transferDataToGPU(spheres.data(), spheres.size() * sizeof(Sphere), &context.compute_sphere_buffer) != 0){
    std::cerr << "transferDataToGPU ERROR - compute_sphere_buffer" << std::endl;
    return -1; 
  }

  if(transferDataToGPU(bvh.data(), bvh.size() * sizeof(BVHNode), &context.compute_bvh_buffer) != 0){
    std::cerr << "transferDataToGPU ERROR - compute_bvh_buffer" << std::endl;
    return -1; 
  }

  return 0;
}

SDL_GPUComputePipeline* loadComputePipeline(const char* rel_path, const char* entry, SDL_GPUShaderFormat format, Uint32 samplers,
    Uint32 r_storage_textures, Uint32 r_storage_buffers, Uint32 rw_storage_textures, Uint32 rw_storage_buffers, Uint32 uniform_buffers,
    Uint32 x, Uint32 y, Uint32 z){
  size_t shader_size;
  void* shader_code = SDL_LoadFile((context.base_path + rel_path).c_str(), &shader_size);
  if(!shader_code){
    std::cerr << "SDL_LoadFile ERROR - " << SDL_GetError() << std::endl;
    return nullptr;
  }

  SDL_GPUComputePipelineCreateInfo shader_info = {
    .code_size = shader_size,
    .code = (Uint8*) shader_code,
    .entrypoint = entry,
    .format = format,
    .num_samplers = samplers,
    .num_readonly_storage_textures = r_storage_textures,
    .num_readonly_storage_buffers = r_storage_buffers,
    .num_readwrite_storage_textures = rw_storage_textures,
    .num_readwrite_storage_buffers = rw_storage_buffers,
    .num_uniform_buffers = uniform_buffers,
    .threadcount_x = x,
    .threadcount_y = y,
    .threadcount_z = z,
    .props = 0
  };
  SDL_GPUComputePipeline* shader_pipeline = SDL_CreateGPUComputePipeline(context.device, &shader_info);
  SDL_free(shader_code);
  if(!shader_pipeline){
    std::cerr << "SDL_CreateGPUComputePipeline ERROR - " << SDL_GetError() << std::endl;
    return nullptr;
  }
  return shader_pipeline;
}

void updateUniformData(){
  context.u_data.aspect_ratio = (float) context.u_data.img_width / context.u_data.img_height;

  glm::vec3 camera_position = glm::vec3(context.u_data.camera_position);
  glm::vec3 camera_look_at = glm::vec3(context.u_data.camera_look_at);
  glm::vec3 up = glm::vec3(context.u_data.up);

  glm::vec3 w = glm::normalize(camera_look_at - camera_position);
  glm::vec3 u = glm::normalize(glm::cross(w, up));
  glm::vec3 v = glm::cross(w, u);

  context.u_data.w = glm::vec4(w, 0.0f);
  context.u_data.u = glm::vec4(u, 0.0f);
  context.u_data.v = glm::vec4(v, 0.0f);

  context.u_data.viewport_w = 4.0f * glm::tan(glm::radians(context.u_data.fov / 2.0f));
  context.u_data.viewport_h = context.u_data.viewport_w / context.u_data.aspect_ratio;

  glm::vec3 viewport_u = context.u_data.viewport_w * u;
  glm::vec3 viewport_v = context.u_data.viewport_h * v;

  context.u_data.viewport_u = glm::vec4(viewport_u, 0.0f);
  context.u_data.viewport_v = glm::vec4(viewport_v, 0.0f);

  glm::vec3 pixel_u = viewport_u / (float) context.u_data.img_width;
  glm::vec3 pixel_v = viewport_v / (float) context.u_data.img_height; 
  
  context.u_data.pixel_u = glm::vec4(pixel_u, 0.0f);
  context.u_data.pixel_v = glm::vec4(pixel_v, 0.0f);

  glm::vec3 pixel00 = camera_position + context.u_data.focus_dist * w;
  pixel00 -= (viewport_u * 0.5f + viewport_v * 0.5f);
  pixel00 += (pixel_u * 0.5f + pixel_v * 0.5f);

  context.u_data.pixel00 = glm::vec4(pixel00, 0.0f);

  float defocus_radius = context.u_data.focus_dist * glm::tan(glm::radians(context.u_data.defocus_angle / 2.0f));
  context.u_data.defocus_disk_u = glm::vec4(u * defocus_radius, 0.0f);
  context.u_data.defocus_disk_v = glm::vec4(v * defocus_radius, 0.0f);
}

SDL_GPUTexture* createScreenSizeRenderTexture(){
  SDL_GetWindowSizeInPixels(context.window, &context.u_data.img_width, &context.u_data.img_height);
  SDL_GPUTextureCreateInfo texture_info = {
    .type = SDL_GPU_TEXTURETYPE_2D,
    .format = SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UNORM,
    .usage = SDL_GPU_TEXTUREUSAGE_SAMPLER | SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_WRITE,
    .width = static_cast<Uint32>(context.u_data.img_width),
    .height = static_cast<Uint32>(context.u_data.img_height),
    .layer_count_or_depth = 1,
    .num_levels = 1,
  };
  SDL_GPUTexture* texture = SDL_CreateGPUTexture(context.device, &texture_info);
  if(!texture){
    std::cerr << "SDL_CreateGPUTexture ERROR - " << SDL_GetError() << std::endl;
    return nullptr;
  }
  return texture;
}

SDL_AppResult SDL_AppInit(void** appstate, int argc, char** argv){ 
  std::srand(std::time({}));

  if(contextInit() != 0){
    return SDL_APP_FAILURE;
  }

#ifdef __APPLE__
  context.compute_pipeline = loadComputePipeline("shaders/metal/compute.metal", "computeMain", SDL_GPU_SHADERFORMAT_MSL,
      0, 0, 2, 1, 0, 1, 8, 8, 1);
#else
  context.compute_pipeline = loadComputePipeline("shaders/spirv/compute.spv", "main", SDL_GPU_SHADERFORMAT_SPIRV, 
      0, 0, 2, 1, 0, 1, 8, 8, 1);
#endif

  if(!context.compute_pipeline){
    return SDL_APP_FAILURE;
  }

  context.compute_render_texture = createScreenSizeRenderTexture();
  if(!context.compute_render_texture){
    return SDL_APP_FAILURE;
  }
  updateUniformData();

  IMGUI_CHECKVERSION();
  ImGui::CreateContext();
  ImGui_ImplSDL3_InitForSDLGPU(context.window);

  ImGui_ImplSDLGPU3_InitInfo init_info = {
    .Device = context.device,
    .ColorTargetFormat = SDL_GetGPUSwapchainTextureFormat(context.device, context.window),
    .MSAASamples = SDL_GPU_SAMPLECOUNT_1
  };
  ImGui_ImplSDLGPU3_Init(&init_info);

  return SDL_APP_CONTINUE;
}

SDL_AppResult SDL_AppIterate(void* appstate){
  context.frame_counter++;
  Uint64 time = SDL_GetTicks();
  if(time - context.last_fps_update >= 1000){
    context.frame_rate = context.frame_counter;
    context.frame_counter = 0;
    context.last_fps_update = time;
  }

  context.u_data.r_seed = std::rand() % 1000;

  ImGui_ImplSDLGPU3_NewFrame();
  ImGui_ImplSDL3_NewFrame();
  ImGui::NewFrame();

  ImGui::Begin("Controls");
  ImGui::Text("FPS: %llu", context.frame_rate);
  if(ImGui::CollapsingHeader("Camera")){
    ImGui::SeparatorText("Position");
    if(ImGui::DragFloat3("##pos", &context.u_data.camera_position[0], 0.1f)){
      updateUniformData();
    }
    ImGui::SeparatorText("Look at");
    if(ImGui::DragFloat3("###look", &context.u_data.camera_look_at[0], 0.1f)){
      updateUniformData();
    }
    ImGui::SeparatorText("FOV");
    if(ImGui::DragFloat("###fov", &context.u_data.fov, 1.0f, 10.0f, 180.0f)){
      updateUniformData();
    }
    ImGui::SeparatorText("Focus distance");
    if(ImGui::DragFloat("##focusdist", &context.u_data.focus_dist, 0.5f, 0.5f, 50.0f)){
      updateUniformData();
    }
    ImGui::SeparatorText("Defocus angle");
    if(ImGui::DragFloat("##defocus", &context.u_data.defocus_angle, 0.5f, 0.0f, 90.0f)){
      updateUniformData();
    }
    ImGui::SeparatorText("Min distance");
    ImGui::DragFloat("##tmin", &context.u_data.t_min, 1.0f, 0.0001f, context.u_data.t_max);
    ImGui::SeparatorText("Max distance");
    ImGui::DragFloat("##tmax", &context.u_data.t_max, 1.0f, context.u_data.t_min, 100000.0f);
  }
  ImGui::SeparatorText("Max bounces");
  ImGui::DragInt("##maxbounces", &context.u_data.max_bounces, 1, 1, 100);
  ImGui::SeparatorText("Samples per pixel");
  ImGui::DragInt("##samples", &context.u_data.samples_per_pixel, 1, 1, 50);
  ImGui::SeparatorText("Use BVH");
  ImGui::DragInt("##usebvh", &context.u_data.use_bvh, 1, 0, 1);
  ImGui::End();

  ImGui::Render();

  SDL_GPUCommandBuffer* command_buffer = SDL_AcquireGPUCommandBuffer(context.device);
  if(!command_buffer){
    std::cerr << "SDL_AcquireGPUCommandBuffer ERROR - " << SDL_GetError() << std::endl;
    return SDL_APP_FAILURE;
  }

  SDL_GPUTexture* swapchainTexture;
  Uint32 width, height;
  SDL_WaitAndAcquireGPUSwapchainTexture(
    command_buffer,
    context.window,
    &swapchainTexture,
    &width,
    &height
  );

  if(!swapchainTexture){
    SDL_SubmitGPUCommandBuffer(command_buffer);
    return SDL_APP_CONTINUE;
  }

  SDL_GPUStorageTextureReadWriteBinding texture_rw_binding[] = {
    {.texture = context.compute_render_texture, .cycle = true }
  };

  SDL_GPUComputePass* compute_pass = SDL_BeginGPUComputePass(
    command_buffer,
    texture_rw_binding,
    1,
    NULL,
    0
  );
  if(!compute_pass){
    std::cerr << "SDL_BeginGPUComputePass ERROR - " << SDL_GetError() << std::endl;
    SDL_SubmitGPUCommandBuffer(command_buffer);
    return SDL_APP_FAILURE;
  }

  SDL_BindGPUComputePipeline(compute_pass, context.compute_pipeline);

  SDL_GPUBuffer* buffers[] = {context.compute_sphere_buffer, context.compute_bvh_buffer};
  SDL_BindGPUComputeStorageBuffers(compute_pass, 0, buffers, 2);

  SDL_PushGPUComputeUniformData(command_buffer, 0, &context.u_data, sizeof(context.u_data));
  SDL_DispatchGPUCompute(compute_pass, width / 8, height / 8, 1);

  SDL_EndGPUComputePass(compute_pass);

  SDL_GPUBlitInfo blit_info = {
    .source = {
      .texture = context.compute_render_texture,
      .w = width,
      .h = height,
    },
    .destination = {
      .texture = swapchainTexture,
      .w = width,
      .h = height,
    },
    .load_op = SDL_GPU_LOADOP_DONT_CARE,
    .filter = SDL_GPU_FILTER_NEAREST
  };
  SDL_BlitGPUTexture(command_buffer, &blit_info);

  Imgui_ImplSDLGPU3_PrepareDrawData(ImGui::GetDrawData(), command_buffer);

  SDL_GPUColorTargetInfo color_target_info = {
    .texture = swapchainTexture,
    .load_op = SDL_GPU_LOADOP_LOAD,
    .store_op = SDL_GPU_STOREOP_STORE
  };

  SDL_GPURenderPass* render_pass = SDL_BeginGPURenderPass(
      command_buffer,
      &color_target_info,
      1,
      NULL
  );

  if(!render_pass){
    std::cerr << "SDL_BeginGPURenderPass ERROR - " << SDL_GetError() << std::endl;
    SDL_SubmitGPUCommandBuffer(command_buffer);
    return SDL_APP_FAILURE;
  }

  ImGui_ImplSDLGPU3_RenderDrawData(ImGui::GetDrawData(), command_buffer, render_pass);

  SDL_EndGPURenderPass(render_pass);

  SDL_SubmitGPUCommandBuffer(command_buffer);

  return SDL_APP_CONTINUE;
}

SDL_AppResult SDL_AppEvent(void* appstate, SDL_Event* event){
  ImGui_ImplSDL3_ProcessEvent(event);

  if(event->type == SDL_EVENT_WINDOW_CLOSE_REQUESTED){
    return SDL_APP_SUCCESS;
  }

  if(event->type == SDL_EVENT_KEY_DOWN && event->key.key == SDLK_I){
      Uint32 is_resizable = SDL_GetWindowFlags(context.window) & SDL_WINDOW_RESIZABLE;
      SDL_SetWindowResizable(context.window, is_resizable == 0);
  }

  if(event->type == SDL_EVENT_WINDOW_RESIZED){
    context.compute_render_texture = createScreenSizeRenderTexture();
    if(!context.compute_render_texture){
      return SDL_APP_FAILURE;
    }
    updateUniformData();
  }

  return SDL_APP_CONTINUE;
}

void SDL_AppQuit(void* appstate, SDL_AppResult result){
  ImGui_ImplSDLGPU3_Shutdown();
  ImGui_ImplSDL3_Shutdown();
  ImGui::DestroyContext();

  SDL_ReleaseGPUBuffer(context.device, context.compute_sphere_buffer);
  SDL_ReleaseGPUTexture(context.device, context.compute_render_texture);
  SDL_ReleaseGPUComputePipeline(context.device, context.compute_pipeline);
  SDL_DestroyGPUDevice(context.device);
  SDL_DestroyWindow(context.window);
}
