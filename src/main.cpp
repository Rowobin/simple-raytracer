#include <iostream>
#include <vector>

#define SDL_MAIN_USE_CALLBACKS
#include <SDL3/SDL.h>
#include <SDL3/SDL_main.h>

#include "imgui.h"
#include "imgui_impl_sdl3.h"
#include "imgui_impl_sdlrenderer3.h"

struct Vertex{
  float x, y, z;
  float r, g, b, a;
};

std::string basePath;
SDL_Window* window;
SDL_GPUDevice* device;
SDL_GPUBuffer* vertexBuffer;
SDL_GPUTransferBuffer* transferBuffer;
SDL_GPUShader* vertexShader;
SDL_GPUShader* fragmentShader;
SDL_GPUGraphicsPipeline* graphicsPipeline;

static Vertex vertices[] = {
  {  0.0f,  0.5f,  0.0f,  1.0f,  0.0f,  0.0f,  1.0f},
  { -0.5f, -0.5f,  0.0f,  0.0f,  1.0f,  0.0f,  1.0f},
  {  0.5f, -0.5f,  0.0f,  0.0f,  0.0f,  1.0f,  1.0f}
};

SDL_AppResult SDL_AppInit(void** appstate, int argc, char** argv){
  window = SDL_CreateWindow(
    "Simple Raytracer | C++20 | SDL3",
    800,
    800,
    SDL_WINDOW_RESIZABLE
  );
  if(!window){
    std::cerr << "SDL_CreateWindow ERROR - " << SDL_GetError() << std::endl;
    return SDL_APP_FAILURE;
  }

  device = SDL_CreateGPUDevice(
#ifdef __APPLE__
    SDL_GPU_SHADERFORMAT_MSL,
#else
    SDL_GPU_SHADERFORMAT_SPIRV,
#endif 
    false,
    NULL
  );
  if(!device){
    std::cerr << "SDL_CreateGPUDevice ERROR - " << SDL_GetError() << std::endl;
    return SDL_APP_FAILURE;
  }

  SDL_ClaimWindowForGPUDevice(device, window);

  basePath = std::string(SDL_GetBasePath());

  size_t vertexCodeSize;
#ifdef __APPLE__
  void* vertexCode = SDL_LoadFile((basePath + "shaders/metal/vert.msl").c_str(), &vertexCodeSize);
#else
  void* vertexCode = SDL_LoadFile((basePath + "shaders/spirv/vert.spv").c_str(), &vertexCodeSize);
#endif
  if(!vertexCode){
    std::cout << "SDL_LoadFile ERROR - " << SDL_GetError() << std::endl;
    return SDL_APP_FAILURE;
  }
  SDL_GPUShaderCreateInfo vertexInfo{};
  vertexInfo.code = (Uint8*) vertexCode;
  vertexInfo.code_size = vertexCodeSize;
#ifdef __APPLE__
  vertexInfo.entrypoint = "main0";
  vertexInfo.format = SDL_GPU_SHADERFORMAT_MSL;
#else
  vertexInfo.entrypoint = "main";
  vertexInfo.format = SDL_GPU_SHADERFORMAT_SPIRV;
#endif
  vertexInfo.stage = SDL_GPU_SHADERSTAGE_VERTEX;
  vertexInfo.num_samplers = 0;
  vertexInfo.num_storage_buffers = 0;
  vertexInfo.num_uniform_buffers = 0;
  vertexShader = SDL_CreateGPUShader(device, &vertexInfo);
  if(!vertexShader){
    std::cout << "SDL_CreateGPUShader ERROR - " << SDL_GetError() << std::endl;
    return SDL_APP_FAILURE;
  }
  SDL_free(vertexCode);

  size_t fragmentCodeSize;
#ifdef __APPLE__
  void* fragmentCode = SDL_LoadFile((basePath + "shaders/metal/frag.msl").c_str(), &fragmentCodeSize);
#else
  void* fragmentCode = SDL_LoadFile((basePath + "shaders/spirv/frag.spv").c_str(), &fragmentCodeSize);
#endif
  if(!fragmentCode){
    std::cout << "SDL_LoadFile ERROR - " << SDL_GetError() << std::endl;
    return SDL_APP_FAILURE;
  }
  SDL_GPUShaderCreateInfo fragmentInfo{};
  fragmentInfo.code = (Uint8*) fragmentCode;
  fragmentInfo.code_size = fragmentCodeSize;
#ifdef __APPLE__
  fragmentInfo.entrypoint = "main0";
  fragmentInfo.format = SDL_GPU_SHADERFORMAT_MSL;
#else
  fragmentInfo.entrypoint = "main";
  fragmentInfo.format = SDL_GPU_SHADERFORMAT_SPIRV;
#endif
  fragmentInfo.stage = SDL_GPU_SHADERSTAGE_FRAGMENT;
  fragmentInfo.num_samplers = 0;
  fragmentInfo.num_storage_textures = 0;
  fragmentInfo.num_uniform_buffers = 0;
  fragmentShader = SDL_CreateGPUShader(device, &fragmentInfo);
  if(!fragmentShader){
    std::cout << "SDL_CreateGPUShader ERROR - " << SDL_GetError() << std::endl;
    return SDL_APP_FAILURE;
  }
  SDL_free(fragmentCode);

  SDL_GPUGraphicsPipelineCreateInfo pipelineInfo{};
  pipelineInfo.vertex_shader = vertexShader;
  pipelineInfo.fragment_shader = fragmentShader;
  pipelineInfo.primitive_type = SDL_GPU_PRIMITIVETYPE_TRIANGLELIST;

  SDL_GPUVertexBufferDescription vertexBufferDescriptions[1];
  vertexBufferDescriptions[0].slot = 0;
  vertexBufferDescriptions[0].input_rate = SDL_GPU_VERTEXINPUTRATE_VERTEX;
  vertexBufferDescriptions[0].instance_step_rate = 0;
  vertexBufferDescriptions[0].pitch = sizeof(Vertex);

  pipelineInfo.vertex_input_state.num_vertex_buffers = 1;
  pipelineInfo.vertex_input_state.vertex_buffer_descriptions = vertexBufferDescriptions;

  SDL_GPUVertexAttribute vertexAttributes[2];
  vertexAttributes[0].buffer_slot = 0;
  vertexAttributes[0].location = 0;
  vertexAttributes[0].format = SDL_GPU_VERTEXELEMENTFORMAT_FLOAT3;
  vertexAttributes[0].offset = 0;
  vertexAttributes[1].buffer_slot = 0;
  vertexAttributes[1].location = 1;
  vertexAttributes[1].format = SDL_GPU_VERTEXELEMENTFORMAT_FLOAT4;
  vertexAttributes[1].offset = 3 * sizeof(float);

  pipelineInfo.vertex_input_state.num_vertex_attributes = 2;
  pipelineInfo.vertex_input_state.vertex_attributes = vertexAttributes;

  SDL_GPUColorTargetDescription colorTargetDescriptions[1];
  colorTargetDescriptions[0] = {};
  colorTargetDescriptions[0].format = SDL_GetGPUSwapchainTextureFormat(device, window);

  pipelineInfo.target_info.num_color_targets = 1;
  pipelineInfo.target_info.color_target_descriptions = colorTargetDescriptions;

  graphicsPipeline = SDL_CreateGPUGraphicsPipeline(device, &pipelineInfo);
  if(!graphicsPipeline){
    std::cout << "SDL_CreateGPUGraphicsPipeline ERROR - " << SDL_GetError() << std::endl;
    return SDL_APP_FAILURE;
  }

  SDL_ReleaseGPUShader(device, vertexShader);
  vertexShader = nullptr;
  SDL_ReleaseGPUShader(device, fragmentShader);
  fragmentShader = nullptr;

  SDL_GPUBufferCreateInfo bufferInfo{};
  bufferInfo.size = sizeof(vertices);
  bufferInfo.usage = SDL_GPU_BUFFERUSAGE_VERTEX;
  vertexBuffer = SDL_CreateGPUBuffer(device, &bufferInfo);
  if(!vertexBuffer){
    std::cerr << "SDL_CreateGPUBuffer ERROR - " << SDL_GetError() << std::endl;
    return SDL_APP_FAILURE;
  }

  SDL_GPUTransferBufferCreateInfo transferInfo{};
  transferInfo.size = sizeof(vertices);
  transferInfo.usage = SDL_GPU_TRANSFERBUFFERUSAGE_UPLOAD;
  transferBuffer = SDL_CreateGPUTransferBuffer(device, &transferInfo);
  if(!transferBuffer){
    std::cerr << "SDL_CreateGPUTransferBuffer ERROR - " << SDL_GetError() << std::endl;
    return SDL_APP_FAILURE;
  }

  Vertex* data = (Vertex*) SDL_MapGPUTransferBuffer(device, transferBuffer, false);
  SDL_memcpy(data, vertices, sizeof(vertices));
  SDL_UnmapGPUTransferBuffer(device, transferBuffer);

  SDL_GPUCommandBuffer* commandBuffer = SDL_AcquireGPUCommandBuffer(device);
  if(!commandBuffer){
    std::cerr << "SDL_AcquireGPUCommandBuffer ERROR - " << SDL_GetError() << std::endl;
    return SDL_APP_FAILURE;
  }

  SDL_GPUCopyPass* copyPass = SDL_BeginGPUCopyPass(commandBuffer);
  SDL_GPUTransferBufferLocation location{};
  location.transfer_buffer = transferBuffer;
  location.offset = 0;

  SDL_GPUBufferRegion region{};
  region.buffer = vertexBuffer;
  region.size = sizeof(vertices);
  region.offset = 0;

  SDL_UploadToGPUBuffer(copyPass, &location, &region, true);

  SDL_EndGPUCopyPass(copyPass);
  SDL_SubmitGPUCommandBuffer(commandBuffer);
  SDL_ReleaseGPUTransferBuffer(device, transferBuffer);
  transferBuffer = nullptr;

  return SDL_APP_CONTINUE;
}

SDL_AppResult SDL_AppIterate(void* appstate){
  SDL_GPUCommandBuffer* commandBuffer = SDL_AcquireGPUCommandBuffer(device);
  if(!commandBuffer){
    std::cerr << "SDL_AcquireGPUCommandBuffer ERROR - " << SDL_GetError() << std::endl;
    return SDL_APP_FAILURE;
  }
  
  SDL_GPUTexture* swapchainTexture;
  Uint32 width, height;
  SDL_WaitAndAcquireGPUSwapchainTexture(
      commandBuffer,
      window, 
      &swapchainTexture,
      &width,
      &height
  );

  if(!swapchainTexture){
    SDL_SubmitGPUCommandBuffer(commandBuffer);
    return SDL_APP_CONTINUE;
  }

  SDL_GPUColorTargetInfo colorTargetInfo{};
  colorTargetInfo.clear_color = {0.8f, 0.8f, 0.8f, 1.0f};
  colorTargetInfo.load_op = SDL_GPU_LOADOP_CLEAR;
  colorTargetInfo.store_op = SDL_GPU_STOREOP_STORE;
  colorTargetInfo.texture = swapchainTexture;

  SDL_GPURenderPass* renderPass = SDL_BeginGPURenderPass(commandBuffer, &colorTargetInfo, 1, NULL);

  SDL_BindGPUGraphicsPipeline(renderPass, graphicsPipeline);

  SDL_GPUBufferBinding bufferBindings[1];
  bufferBindings[0].buffer = vertexBuffer;
  bufferBindings[0].offset = 0;

  SDL_BindGPUVertexBuffers(renderPass, 0, bufferBindings, 1);

  SDL_DrawGPUPrimitives(renderPass, 3, 1, 0, 0);

  SDL_EndGPURenderPass(renderPass);

  SDL_SubmitGPUCommandBuffer(commandBuffer);

  return SDL_APP_CONTINUE;
}

SDL_AppResult SDL_AppEvent(void* appstate, SDL_Event* event){
  if(event->type == SDL_EVENT_WINDOW_CLOSE_REQUESTED){
    return SDL_APP_SUCCESS;
  }

  return SDL_APP_CONTINUE;
}

void SDL_AppQuit(void* appstate, SDL_AppResult result){
  if(device){
    if(graphicsPipeline) SDL_ReleaseGPUGraphicsPipeline(device, graphicsPipeline);
    if(fragmentShader) SDL_ReleaseGPUShader(device, fragmentShader);
    if(vertexShader) SDL_ReleaseGPUShader(device, vertexShader);
    if(transferBuffer) SDL_ReleaseGPUTransferBuffer(device, transferBuffer);
    if(vertexBuffer) SDL_ReleaseGPUBuffer(device, vertexBuffer);
    SDL_DestroyGPUDevice(device);
  }
  if(window) SDL_DestroyWindow(window);
}
