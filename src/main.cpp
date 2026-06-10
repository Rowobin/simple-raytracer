#include <iostream>
#include <vector>

#define SDL_MAIN_USE_CALLBACKS
#include <SDL3/SDL.h>
#include <SDL3/SDL_main.h>

#include "imgui.h"
#include "imgui_impl_sdl3.h"
#include "imgui_impl_sdlgpu3.h"

struct UniformData{
  int img_width;
  int img_height;
};

struct Context{
  std::string base_path;
  SDL_Window* window;
  SDL_GPUDevice* device;
  SDL_GPUComputePipeline* compute_pipeline;
  SDL_GPUTexture* compute_render_texture;
  UniformData compute_uniform_data;
  Uint64 frame_counter;
  Uint64 last_fps_update;
  Uint64 frame_rate;
};
Context context;

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

SDL_GPUTexture* createScreenSizeRenderTexture(){
  SDL_GetWindowSizeInPixels(context.window, &context.compute_uniform_data.img_width, &context.compute_uniform_data.img_height);
  SDL_GPUTextureCreateInfo texture_info = {
    .format = SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UNORM,
    .type = SDL_GPU_TEXTURETYPE_2D,
    .width = static_cast<Uint32>(context.compute_uniform_data.img_width),
    .height = static_cast<Uint32>(context.compute_uniform_data.img_height),
    .layer_count_or_depth = 1,
    .num_levels = 1,
    .usage = SDL_GPU_TEXTUREUSAGE_SAMPLER | SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_WRITE,
  };
  SDL_GPUTexture* texture = SDL_CreateGPUTexture(context.device, &texture_info);
  if(!texture){
    std::cerr << "SDL_CreateGPUTexture ERROR - " << SDL_GetError() << std::endl;
    return nullptr;
  }
  return texture;
}

SDL_AppResult SDL_AppInit(void** appstate, int argc, char** argv){ 
  if(contextInit() != 0){
    return SDL_APP_FAILURE;
  }

#ifdef __APPLE__
  context.compute_pipeline = loadComputePipeline("shaders/metal/compute.metal", "computeMain", SDL_GPU_SHADERFORMAT_MSL,
      0, 0, 0, 1, 0, 1, 8, 8, 1);
#else
  context.compute_pipeline = loadComputePipeline("shaders/spirv/compute.spv", "main", SDL_GPU_SHADERFORMAT_SPIRV, 
      0, 0, 0, 1, 0, 1, 8, 8, 1);
#endif

  if(!context.compute_pipeline){
    return SDL_APP_FAILURE;
  }

  context.compute_render_texture = createScreenSizeRenderTexture();
  if(!context.compute_render_texture){
    return SDL_APP_FAILURE;
  }

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

  ImGui_ImplSDLGPU3_NewFrame();
  ImGui_ImplSDL3_NewFrame();
  ImGui::NewFrame();

  ImGui::Begin("Controls");
  ImGui::Text("FPS: %llu", context.frame_rate);
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
  SDL_PushGPUComputeUniformData(command_buffer, 0, &context.compute_uniform_data, sizeof(context.compute_uniform_data));
  SDL_DispatchGPUCompute(compute_pass, width / 8, height / 8, 1);

  SDL_EndGPUComputePass(compute_pass);

  SDL_GPUBlitInfo blit_info = {
    .source.texture = context.compute_render_texture,
    .source.w = width,
    .source.h = height,
    .destination.texture = swapchainTexture,
    .destination.w = width,
    .destination.h = height,
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
  }

  return SDL_APP_CONTINUE;
}

void SDL_AppQuit(void* appstate, SDL_AppResult result){
  ImGui_ImplSDLGPU3_Shutdown();
  ImGui_ImplSDL3_Shutdown();
  ImGui::DestroyContext();

  SDL_ReleaseGPUTexture(context.device, context.compute_render_texture);
  SDL_ReleaseGPUComputePipeline(context.device, context.compute_pipeline);
  SDL_DestroyGPUDevice(context.device);
  SDL_DestroyWindow(context.window);
}

