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

struct Uniform{
  float time;
};

struct Context{
  std::string basePath;
  Uniform uniformData;
  SDL_Window* window;
  SDL_GPUDevice* device;
  SDL_GPUBuffer* vertexBuffer;
  SDL_GPUGraphicsPipeline* graphicsPipelineStandard;
};
Context context;

int contextInit(Context* context){
  context->window = SDL_CreateWindow("Simple Raytracer", 800, 800, SDL_WINDOW_RESIZABLE);
  if(!context->window){
    std::cerr << "SDL_CreateWindow ERROR - " << SDL_GetError() << std::endl;
    return -1;
  }
  
  context->device = SDL_CreateGPUDevice(
#ifdef __APPLE__
    SDL_GPU_SHADERFORMAT_MSL,
#else
    SDL_GPU_SHADERFORMAT_SPIRV,
#endif
    false,
    NULL
  );
  if(!context->device){
    std::cerr << "SDL_CreateGPUDevice ERROR - " << SDL_GetError() << std::endl;
    return -1;
  }
  SDL_ClaimWindowForGPUDevice(context->device, context->window);

  context->basePath = std::string(SDL_GetBasePath());
  return 0;
}

SDL_GPUShader* loadShader(Context* context, const char* relPath, const char* entry, SDL_GPUShaderFormat format, SDL_GPUShaderStage stage,
    Uint32 samplers, Uint32 storage_textures, Uint32 storage_buffers, Uint32 uniform_buffers){
  size_t shaderSize;
  void* shaderCode = SDL_LoadFile((context->basePath + relPath).c_str(), &shaderSize);
  if(!shaderCode){
    std::cerr << "SDL_LoadFile ERROR - " << SDL_GetError() << std::endl;
    return nullptr;
  }
  SDL_GPUShaderCreateInfo shaderInfo{
    .code = (Uint8*) shaderCode,
    .code_size = shaderSize,
    .entrypoint = entry,
    .format = format,
    .stage = stage,
    .num_samplers = samplers,
    .num_storage_textures = storage_textures,
    .num_storage_buffers = storage_buffers,
    .num_uniform_buffers = uniform_buffers
  };
  SDL_GPUShader* shader = SDL_CreateGPUShader(context->device, &shaderInfo);
  SDL_free(shaderCode);
  if(!shader){
    std::cerr << "SDL_CreateGPUShader ERROR - " << SDL_GetError() << std::endl;
    return nullptr;
  }
  return shader;
}
  
SDL_AppResult SDL_AppInit(void** appstate, int argc, char** argv){

  if(contextInit(&context) == -1){
    return SDL_APP_FAILURE;
  }

#ifdef __APPLE__
  SDL_GPUShader* vertexShader = loadShader(&context, "shaders/metal/vertex.metal", "vertexMain", SDL_GPU_SHADERFORMAT_MSL, 
      SDL_GPU_SHADERSTAGE_VERTEX, 0, 0, 0, 0);
  SDL_GPUShader* fragmentShader = loadShader(&context, "shaders/metal/fragment.metal", "fragmentMain", SDL_GPU_SHADERFORMAT_MSL,
      SDL_GPU_SHADERSTAGE_FRAGMENT, 0, 0, 0, 1);
#else
  SDL_GPUShader* vertexShader = loadShader(&context, "shaders/spirv/vertex.spv", "vertexMain", SDL_GPU_SHADERFORMAT_SPIRV,
      SDL_GPU_SHADERSTAGE_VERTEX, 0, 0, 0, 0);
  SDL_GPUShader* fragmentShader = loadShader(&context, "shaders/spirv/fragment.spv", "fragmentMain", SDL_GPU_SHADERFORMAT_SPIRV,
      SDL_GPU_SHADERSTAGE_FRAGMENT, 0, 0, 0, 1);
#endif

  if(!vertexShader || !fragmentShader){
    return SDL_APP_FAILURE;
  }

  SDL_GPUVertexBufferDescription vertexBufferDescription[1] = {
    {.slot = 0, .input_rate = SDL_GPU_VERTEXINPUTRATE_VERTEX, .instance_step_rate = 0, .pitch = sizeof(Vertex)}
  };

  SDL_GPUVertexAttribute vertexAttribute[2] = {
    {.buffer_slot = 0, .location = 0, .format = SDL_GPU_VERTEXELEMENTFORMAT_FLOAT3, .offset = 0},
    {.buffer_slot = 0, .location = 1, .format = SDL_GPU_VERTEXELEMENTFORMAT_FLOAT4, .offset = 3 * sizeof(float)}
  };

  SDL_GPUColorTargetDescription colorTargetDescription[1] = {
    {.format = SDL_GetGPUSwapchainTextureFormat(context.device, context.window)}
  };

  SDL_GPUGraphicsPipelineCreateInfo pipelineInfo{
    .vertex_shader = vertexShader,
    .fragment_shader = fragmentShader,
    .primitive_type = SDL_GPU_PRIMITIVETYPE_TRIANGLELIST,
    .vertex_input_state.num_vertex_buffers = 1,
    .vertex_input_state.vertex_buffer_descriptions = vertexBufferDescription,
    .vertex_input_state.num_vertex_attributes = 2,
    .vertex_input_state.vertex_attributes = vertexAttribute,
    .target_info.num_color_targets = 1,
    .target_info.color_target_descriptions = colorTargetDescription
  };

  context.graphicsPipelineStandard = SDL_CreateGPUGraphicsPipeline(context.device, &pipelineInfo);
  if(!context.graphicsPipelineStandard){
    std::cout << "SDL_CreateGPUGraphicsPipeline ERROR - " << SDL_GetError() << std::endl;
    return SDL_APP_FAILURE;
  }

  SDL_ReleaseGPUShader(context.device, vertexShader);
  SDL_ReleaseGPUShader(context.device, fragmentShader);

  Vertex vertices[] = {
    {  0.0f,  0.5f,  0.0f,  1.0f,  0.0f,  0.0f,  1.0f},
    { -0.5f, -0.5f,  0.0f,  0.0f,  1.0f,  0.0f,  1.0f},
    {  0.5f, -0.5f,  0.0f,  0.0f,  0.0f,  1.0f,  1.0f}
  };

  SDL_GPUBufferCreateInfo bufferInfo{
    .size = sizeof(vertices),
    .usage = SDL_GPU_BUFFERUSAGE_VERTEX,
  };
  context.vertexBuffer = SDL_CreateGPUBuffer(context.device, &bufferInfo);
  if(!context.vertexBuffer){
    std::cerr << "SDL_CreateGPUBuffer ERROR - " << SDL_GetError() << std::endl;
    return SDL_APP_FAILURE;
  }

  SDL_GPUTransferBufferCreateInfo transferInfo{
    .size = sizeof(vertices),
    .usage = SDL_GPU_TRANSFERBUFFERUSAGE_UPLOAD
  };
  SDL_GPUTransferBuffer* transferBuffer = SDL_CreateGPUTransferBuffer(context.device, &transferInfo);
  if(!transferBuffer){
    std::cerr << "SDL_CreateGPUTransferBuffer ERROR - " << SDL_GetError() << std::endl;
    return SDL_APP_FAILURE;
  }

  Vertex* data = (Vertex*) SDL_MapGPUTransferBuffer(context.device, transferBuffer, false);
  SDL_memcpy(data, vertices, sizeof(vertices));
  SDL_UnmapGPUTransferBuffer(context.device, transferBuffer);

  SDL_GPUCommandBuffer* commandBuffer = SDL_AcquireGPUCommandBuffer(context.device);
  if(!commandBuffer){
    std::cerr << "SDL_AcquireGPUCommandBuffer ERROR - " << SDL_GetError() << std::endl;
    return SDL_APP_FAILURE;
  }

  SDL_GPUCopyPass* copyPass = SDL_BeginGPUCopyPass(commandBuffer);
  SDL_GPUTransferBufferLocation location{
    .transfer_buffer = transferBuffer,
    .offset = 0
  };

  SDL_GPUBufferRegion region{
    .buffer = context.vertexBuffer,
    .size = sizeof(vertices),
    .offset = 0
  };
  SDL_UploadToGPUBuffer(copyPass, &location, &region, true);
  SDL_EndGPUCopyPass(copyPass);

  SDL_SubmitGPUCommandBuffer(commandBuffer);

  SDL_ReleaseGPUTransferBuffer(context.device, transferBuffer);

  return SDL_APP_CONTINUE;
}

SDL_AppResult SDL_AppIterate(void* appstate){
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

  SDL_GPUColorTargetInfo colorTargetInfo{
    .clear_color = {0.8f, 0.8f, 0.8f, 1.0f},
    .load_op = SDL_GPU_LOADOP_CLEAR,
    .store_op = SDL_GPU_STOREOP_STORE,
    .texture = swapchainTexture,
  };

  SDL_GPURenderPass* renderPass = SDL_BeginGPURenderPass(commandBuffer, &colorTargetInfo, 1, NULL);

  SDL_BindGPUGraphicsPipeline(renderPass, context.graphicsPipelineStandard);

  SDL_GPUBufferBinding bufferBindings[1];
  bufferBindings[0].buffer = context.vertexBuffer;
  bufferBindings[0].offset = 0;

  SDL_BindGPUVertexBuffers(renderPass, 0, bufferBindings, 1);

  context.uniformData.time = SDL_GetTicksNS() / 1e9f;
  SDL_PushGPUFragmentUniformData(commandBuffer, 0, &context.uniformData, sizeof(Uniform));

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
  SDL_ReleaseGPUGraphicsPipeline(context.device, context.graphicsPipelineStandard);
  SDL_ReleaseGPUBuffer(context.device, context.vertexBuffer);
  SDL_DestroyGPUDevice(context.device);
  SDL_DestroyWindow(context.window);
}
