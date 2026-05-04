#include <iostream>
#include <vector>

#include <SDL3/SDL.h>
#include <SDL3/SDL_main.h>

#include "imgui.h"
#include "imgui_impl_sdl3.h"
#include "imgui_impl_sdlrenderer3.h"

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

int main(int agrc, char* argv[]) {
  // Init SDL
  if(!SDL_Init(SDL_INIT_VIDEO)) {
    std::cerr << "SDL_Init Error: " << SDL_GetError() << std::endl;
    return 1;
  }

  // Create window
  SDL_Window* window = SDL_CreateWindow(
    "Simple Raytracer - SDL3 - C++20",
    800,
    800,
    SDL_WINDOW_RESIZABLE
  );
  if(!window){
    std::cerr << "SDL_CreateWindow Error: " << SDL_GetError() << std::endl;
    SDL_Quit();
    return 1;
  }

  // Create renderer
  SDL_Renderer* renderer = SDL_CreateRenderer(window, nullptr);
  if(!renderer){
    std::cerr << "SDL_CreateRenderer Error: " << SDL_GetError() << std::endl;
    SDL_DestroyWindow(window);
    SDL_Quit();
    return 1;
  }

  // Create a texture we can write to (streaming = CPU writable)
  SDL_Texture* texture = SDL_CreateTexture(
    renderer,
    SDL_PIXELFORMAT_RGBA8888,
    SDL_TEXTUREACCESS_STREAMING,
    32,
    32 
  );
  if(!texture){
    std::cerr << "SDL_CreateTexture Error: " << SDL_GetError() << std::endl;
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
    return 1;
  }
  SDL_SetTextureScaleMode(texture, SDL_SCALEMODE_NEAREST);
  Uint8 blueValue = 0;
  RebuildTextureBlue(texture, blueValue);

  // ImGui init
  IMGUI_CHECKVERSION();
  ImGui::CreateContext();
  ImGui::StyleColorsDark();
  ImGui_ImplSDL3_InitForSDLRenderer(window, renderer);
  ImGui_ImplSDLRenderer3_Init(renderer);

  std::cout << "Press ESC or close the window to quit!\n";

  bool running = true;
  SDL_Event event;

  while(running){
    // Event handling
    if(SDL_PollEvent(&event)){
      ImGui_ImplSDL3_ProcessEvent(&event);

      if(event.type == SDL_EVENT_QUIT){
        running = false;  
      }
      if(event.type == SDL_EVENT_KEY_DOWN){
        if(event.key.key == SDLK_ESCAPE){
          running = false;
        }
      }
    }

    // ImGui frame
    ImGui_ImplSDLRenderer3_NewFrame();
    ImGui_ImplSDL3_NewFrame();
    ImGui::NewFrame();

    ImGui::SetNextWindowSize(ImVec2(256, 256), ImGuiCond_FirstUseEver);
    ImGui::Begin("Texture Controls");
    ImGui::Text("Blue channel:");

    int blue = blueValue;

    ImVec4 swatch(0.0f, 0.0f, blue / 255.0f, 1.0f);
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

    // Render
    SDL_RenderClear(renderer);
    SDL_RenderTexture(renderer, texture, nullptr, nullptr);
    ImGui_ImplSDLRenderer3_RenderDrawData(ImGui::GetDrawData(), renderer);
    SDL_RenderPresent(renderer);
  }

  // Clean up before closing 
  ImGui_ImplSDLRenderer3_Shutdown();
  ImGui_ImplSDL3_Shutdown();
  ImGui::DestroyContext();

  SDL_DestroyTexture(texture);
  SDL_DestroyRenderer(renderer);
  SDL_DestroyWindow(window);
  SDL_Quit();

  std::cout << "Window closed. Goodbye!\n";

  return 0;
}
