#include <iostream>
#include <vector>

#define SDL_MAIN_USE_CALLBACKS
#include <SDL3/SDL.h>
#include <SDL3/SDL_main.h>

#include "imgui.h"
#include "imgui_impl_sdl3.h"
#include "imgui_impl_sdlgpu3.h"

struct ComputeUniform{
  int wWidth;
  int wHeight;
};

struct Context{
  std::string basePath;
  SDL_Window* window;
  SDL_GPUDevice* device;
  SDL_GPUComputePipeline* computePipeline;
  SDL_GPUTexture* computeRenderTexture;
  ComputeUniform computeUniformData;
};
Context context;

int contextInit(Context* contextRef){
  contextRef->window = SDL_CreateWindow("Simple Raytracer", 800, 450, 0);
  if(!contextRef->window){
    std::cerr << "SDL_CreateWindow ERROR - " << SDL_GetError() << std::endl;
    return -1;
  }
  
  contextRef->device = SDL_CreateGPUDevice(
#ifdef __APPLE__
    SDL_GPU_SHADERFORMAT_MSL,
#else
    SDL_GPU_SHADERFORMAT_SPIRV,
#endif
    false,
    NULL
  );
  if(!contextRef->device){
    std::cerr << "SDL_CreateGPUDevice ERROR - " << SDL_GetError() << std::endl;
    return -1;
  }
  SDL_ClaimWindowForGPUDevice(contextRef->device, contextRef->window);

  contextRef->basePath = std::string(SDL_GetBasePath());
  return 0;
}

SDL_GPUComputePipeline* loadComputePipeline(Context* contextRef, const char* relPath, const char* entry, SDL_GPUShaderFormat format, Uint32 samplers,
    Uint32 r_storage_textures, Uint32 r_storage_buffers, Uint32 rw_storage_textures, Uint32 rw_storage_buffers, Uint32 uniform_buffers,
    Uint32 x, Uint32 y, Uint32 z){
  size_t computeShaderSize;
  void* computeShaderCode = SDL_LoadFile((contextRef->basePath + relPath).c_str(), &computeShaderSize);
  if(!computeShaderCode){
    std::cerr << "SDL_LoadFile ERROR - " << SDL_GetError() << std::endl;
    return nullptr;
  }
  SDL_GPUComputePipelineCreateInfo computeShaderInfo{
    .code_size = computeShaderSize,
    .code = (Uint8*) computeShaderCode,
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
  SDL_GPUComputePipeline* computePipeline = SDL_CreateGPUComputePipeline(contextRef->device, &computeShaderInfo);
  SDL_free(computeShaderCode);
  if(!computePipeline){
    std::cerr << "SDL_CreateGPUComputePipeline ERROR - " << SDL_GetError() << std::endl;
    return nullptr;
  }
  return computePipeline;
}

SDL_GPUTexture* createScreenSizeRenderTexture(Context* context){
  SDL_GetWindowSizeInPixels(context->window, &context->computeUniformData.wWidth, &context->computeUniformData.wHeight);
  SDL_GPUTextureCreateInfo gpuTextureCreateInfo{
    .format = SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UNORM,
    .type = SDL_GPU_TEXTURETYPE_2D,
    .width = static_cast<Uint32>(context->computeUniformData.wWidth),
    .height = static_cast<Uint32>(context->computeUniformData.wHeight),
    .layer_count_or_depth = 1,
    .num_levels = 1,
    .usage = SDL_GPU_TEXTUREUSAGE_SAMPLER | SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_WRITE
  };
  SDL_GPUTexture* texture = SDL_CreateGPUTexture(
    context->device,
    &gpuTextureCreateInfo
  );
  if(!texture){
    std::cerr << "SDL_CreateGPUTexture ERROR - " << SDL_GetError() << std::endl;
    return nullptr;
  }
  return texture;
}

SDL_AppResult SDL_AppInit(void** appstate, int argc, char** argv){
  if(contextInit(&context) == -1){
    return SDL_APP_FAILURE;
  }

#ifdef __APPLE__
  context.computePipeline = loadComputePipeline(&context, "shaders/metal/compute.metal", "computeMain", SDL_GPU_SHADERFORMAT_MSL,
      0, 0, 0, 1, 0, 1, 8, 8, 1);
#else
  context.computePipeline = loadComputePipeline(&context, "shaders/spirv/compute.spv", "main", SDL_GPU_SHADERFORMAT_SPIRV,
      0, 0, 0, 1, 0, 1, 8, 8, 1);
#endif

  if(!context.computePipeline){
    return SDL_APP_FAILURE;
  }

  context.computeRenderTexture = createScreenSizeRenderTexture(&context);
  if(!context.computeRenderTexture){
    return SDL_APP_FAILURE;
  }
  
  IMGUI_CHECKVERSION();
  ImGui::CreateContext();
  ImGui_ImplSDL3_InitForSDLGPU(context.window);

  ImGui_ImplSDLGPU3_InitInfo initInfo{
    .Device = context.device,
    .ColorTargetFormat = SDL_GetGPUSwapchainTextureFormat(context.device, context.window),
    .MSAASamples = SDL_GPU_SAMPLECOUNT_1
  };

  ImGui_ImplSDLGPU3_Init(&initInfo);

  return SDL_APP_CONTINUE;
}

SDL_AppResult SDL_AppIterate(void* appstate){
  ImGui_ImplSDLGPU3_NewFrame();
  ImGui_ImplSDL3_NewFrame();
  ImGui::NewFrame();

  ImGui::Begin("Controls");
  ImGui::Text("words words words");
  ImGui::End();

  ImGui::Render();

  SDL_GPUCommandBuffer* commandBuffer = SDL_AcquireGPUCommandBuffer(context.device);
  if(!commandBuffer){
    std::cerr << "SDL_AcquireGPUCommandBuffer ERROR - " << SDL_GetError() << std::endl;
    return SDL_APP_FAILURE;
  }
  
  SDL_GPUTexture* swapchainTexture;
  Uint32 width, height;
  SDL_WaitAndAcquireGPUSwapchainTexture(
      commandBuffer,
      context.window, 
      &swapchainTexture,
      &width,
      &height
  );

  if(!swapchainTexture){
    SDL_SubmitGPUCommandBuffer(commandBuffer);
    return SDL_APP_CONTINUE;
  }

  SDL_GPUStorageTextureReadWriteBinding gpuStorageTextureReadWriteBinding[] = {
    {.texture = context.computeRenderTexture, .cycle = true}
  };

  SDL_GPUComputePass* computePass = SDL_BeginGPUComputePass(
    commandBuffer,
    gpuStorageTextureReadWriteBinding,
    1,
    NULL,
    0
  );

  SDL_BindGPUComputePipeline(computePass, context.computePipeline);
  SDL_PushGPUComputeUniformData(commandBuffer, 0, &context.computeUniformData, sizeof(context.computeUniformData));
  SDL_DispatchGPUCompute(computePass, width / 8, height / 8, 1);

  SDL_EndGPUComputePass(computePass);

  SDL_GPUBlitInfo gpuBlitInfo = {
    .source.texture = context.computeRenderTexture,
    .source.w = width,
    .source.h = height,
    .destination.texture = swapchainTexture,
    .destination.w = width,
    .destination.h = height,
    .load_op = SDL_GPU_LOADOP_DONT_CARE,
    .filter = SDL_GPU_FILTER_NEAREST
  };

  SDL_BlitGPUTexture(
    commandBuffer,
    &gpuBlitInfo 
  );

  Imgui_ImplSDLGPU3_PrepareDrawData(ImGui::GetDrawData(), commandBuffer);

  SDL_GPUColorTargetInfo colorTargetInfo{
    .texture = swapchainTexture,
    .load_op = SDL_GPU_LOADOP_LOAD,
    .store_op = SDL_GPU_STOREOP_STORE
  };
  
  SDL_GPURenderPass* renderPass = SDL_BeginGPURenderPass(
    commandBuffer,
    &colorTargetInfo,
    1,
    NULL
  );

  if(!renderPass){
    std::cerr << "SDL_BeginGPURenderPass ERROR - " << SDL_GetError() << std::endl;
    SDL_SubmitGPUCommandBuffer(commandBuffer);
    return SDL_APP_FAILURE;
  }

  ImGui_ImplSDLGPU3_RenderDrawData(ImGui::GetDrawData(), commandBuffer, renderPass);
  
  SDL_EndGPURenderPass(renderPass);

  SDL_SubmitGPUCommandBuffer(commandBuffer);

  return SDL_APP_CONTINUE;
}

SDL_AppResult SDL_AppEvent(void* appstate, SDL_Event* event){
  ImGui_ImplSDL3_ProcessEvent(event);

  if(event->type == SDL_EVENT_WINDOW_CLOSE_REQUESTED){
    return SDL_APP_SUCCESS;
  }

  if(event->type == SDL_EVENT_KEY_DOWN && event->key.key == SDLK_I){
    Uint32 IsResizable = SDL_GetWindowFlags(context.window) & SDL_WINDOW_RESIZABLE;
    SDL_SetWindowResizable(context.window, IsResizable == 0);
  }

  if(event->type == SDL_EVENT_WINDOW_RESIZED){
    context.computeRenderTexture = createScreenSizeRenderTexture(&context);
    if(!context.computeRenderTexture){
      return SDL_APP_CONTINUE;
    }
  }

  return SDL_APP_CONTINUE;
}

void SDL_AppQuit(void* appstate, SDL_AppResult result){
  ImGui_ImplSDLGPU3_Shutdown();
  ImGui_ImplSDL3_Shutdown();
  ImGui::DestroyContext();

  SDL_ReleaseGPUTexture(context.device, context.computeRenderTexture);
  SDL_ReleaseGPUComputePipeline(context.device, context.computePipeline);
  SDL_DestroyGPUDevice(context.device);
  SDL_DestroyWindow(context.window);
}
