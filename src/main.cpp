#include <iostream>
#include <vector>

#define SDL_MAIN_USE_CALLBACKS
#include <SDL3/SDL.h>
#include <SDL3/SDL_main.h>

#include "imgui.h"
#include "imgui_impl_sdl3.h"
#include "imgui_impl_sdlrenderer3.h"

SDL_Window* window;
SDL_Renderer* renderer;
SDL_Texture* texture;
Uint8 blueValue;

void RebuildTextureBlue(SDL_Texture* texture, Uint8 blue){
  std::vector<Uint32> pixels(texture->w * texture->h);
  for(int y = 0; y < texture->h; y++){
    for(int x = 0; x < texture->w; x++){
      Uint8 r = static_cast<Uint8>((float) x / texture->w * 255);
      Uint8 g = static_cast<Uint8>((float) y / texture->h * 255);
      Uint8 b = blue;
      Uint8 a = 255;
      pixels[texture->w * y + x] = ( (Uint32) r << 24 | (Uint32) g << 16 | (Uint32) b << 8 | (Uint32) a);
    }
  }
  SDL_UpdateTexture(texture, nullptr, pixels.data(), texture->w * sizeof(Uint32));
}

SDL_AppResult SDL_AppInit(void** appstate, int argc, char**argv){
  window = SDL_CreateWindow(
    "Simple Raytracer - C++20 - SDL3",
    800,
    800,
    SDL_WINDOW_RESIZABLE
  );

  if(!window){
    std::cerr << "SDL_CreateWindow Error: " << SDL_GetError() << std::endl;
    return SDL_APP_FAILURE;
  }

  SDL_SetWindowSize(window, 800, 800);
  SDL_SetWindowResizable(window, true);

  renderer = SDL_CreateRenderer(
    window,
    nullptr
  );

  if(!renderer){
    std::cerr << "SDL_CreateRenderer Error: " << SDL_GetError() << std::endl;
    return SDL_APP_FAILURE;
  }

  texture = SDL_CreateTexture(
    renderer,
    SDL_PIXELFORMAT_RGBA8888,
    SDL_TEXTUREACCESS_STREAMING,
    32,
    32
  ); 

  if(!texture){
    std::cerr << "SDL_CreateTexture Error: " << SDL_GetError() << std::endl;
    return SDL_APP_FAILURE;
  }

  SDL_SetTextureScaleMode(texture, SDL_SCALEMODE_NEAREST);
  blueValue = 0;
  RebuildTextureBlue(texture, blueValue);

  IMGUI_CHECKVERSION();
  ImGui::CreateContext();
  ImGui::StyleColorsDark();
  ImGui_ImplSDL3_InitForSDLRenderer(window, renderer);
  ImGui_ImplSDLRenderer3_Init(renderer);

  return SDL_APP_CONTINUE;
}

SDL_AppResult SDL_AppIterate(void* appstate){
  //ImGui frame
  ImGui_ImplSDLRenderer3_NewFrame();
  ImGui_ImplSDL3_NewFrame();
  ImGui::NewFrame();

  ImGui::SetNextWindowSize(ImVec2(256, 256), ImGuiCond_FirstUseEver);
  ImGui::Begin("Texture Controls");
  ImGui::Text("Blue channel:");

  int blue = blueValue;
  ImVec4 swatch(0.0f, 0.0f, blue/255.0f, 1.0f);
  ImGui::ColorButton(
    "##preview",
    swatch,
    ImGuiColorEditFlags_NoTooltip | ImGuiColorEditFlags_NoBorder,
    ImVec2(24, 24)
  );

  ImGui::SameLine();

  if(ImGui::SliderInt("Blue", &blue, 0, 255)){
    blueValue = static_cast<Uint8>(blue);
    RebuildTextureBlue(texture, blueValue);
  }

  ImGui::End();
  ImGui::Render();

  int window_w, window_h;
  SDL_GetWindowSize(window, &window_w, &window_h);
  float win_ratio = window_w / static_cast<float>(window_h);
  
  float tex_ratio = texture->w / static_cast<float>(texture->h);
  SDL_FRect dstrect;

  if(win_ratio >= tex_ratio){ 
    dstrect.h = window_h;
    dstrect.w = dstrect.h * tex_ratio;
    dstrect.x = (window_w - dstrect.w) / 2.0f;
    dstrect.y = 0.0f;
  } else {
    dstrect.w = window_w;
    dstrect.h = dstrect.w / tex_ratio;
    dstrect.x = 0.0f;
    dstrect.y = (window_h - dstrect.h) / 2.0f;
  }
  
  SDL_RenderClear(renderer);
  SDL_RenderTexture(renderer, texture, nullptr, &dstrect);
  ImGui_ImplSDLRenderer3_RenderDrawData(ImGui::GetDrawData(), renderer);
  SDL_RenderPresent(renderer);

  return SDL_APP_CONTINUE;
}

SDL_AppResult SDL_AppEvent(void* appstate, SDL_Event* event){
  ImGui_ImplSDL3_ProcessEvent(event);

  if(event->type == SDL_EVENT_QUIT){
    return SDL_APP_SUCCESS;
  } 

  return SDL_APP_CONTINUE;
}

void SDL_AppQuit(void* appstate, SDL_AppResult result){
  ImGui_ImplSDLRenderer3_Shutdown();
  ImGui_ImplSDL3_Shutdown();
  ImGui::DestroyContext();

  SDL_DestroyTexture(texture);
  SDL_DestroyRenderer(renderer);
  SDL_DestroyWindow(window);
}
