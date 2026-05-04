# Building and running simple-raytracer

# On Windows

# mkdir build
# cd build
# cmake -DCMAKE_BUILD_TYPE=Release ..
# cmake --build . --config Release
# .\Release\simple_raytracer.exe

# On MacOS/Linux

# mkdir build
# cd build
# cmake -DCMAKE_BUILD_TYPE=Release ..
# cmake --build . --config Release
# ./simple_raytracer

cmake_minimum_required(VERSION 3.10)

project(SimpleRaytracer VERSION 1.0 LANGUAGES CXX)

# Use C++20
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED True)
set(CMAKE_CXX_EXTENSIONS OFF)

# Turn on compiler warnings
add_compile_options(
  $<$<CXX_COMPILER_ID:GNU,Clang>:-Wall>
  $<$<CXX_COMPILER_ID:GNU,Clang>:-Wextra>
  $<$<CXX_COMPILER_ID:GNU,Clang>:-Wpedantic>
  $<$<CXX_COMPILER_ID:MSVC>:/W4>
)

# Include external libraries via FetchContent
include(FetchContent)

# SDL3
FetchContent_Declare(
  SDL3
  GIT_REPOSITORY  https://github.com/libsdl-org/SDL.git
  GIT_TAG         release-3.4.8
  GIT_SHALLOW     TRUE
)
# Do not build SDL3 as a dynamic/shared library (SDL3.dll)
set(SDL_SHARED OFF CACHE BOOL "" FORCE)
# Build SDL3 as a static library (SDL3-static.lib)
set(SDL_STATIC ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(SDL3)

# ImGui
FetchContent_Declare(
  imgui
  GIT_REPOSITORY https://github.com/ocornut/imgui.git
  GIT_TAG v1.91.9b
  GIT_SHALLOW TRUE
)
FetchContent_MakeAvailable(imgui)

# Compile ImGui as a static library
add_library(imgui_lib STATIC
  ${imgui_SOURCE_DIR}/imgui.cpp
  ${imgui_SOURCE_DIR}/imgui_draw.cpp
  ${imgui_SOURCE_DIR}/imgui_tables.cpp
  ${imgui_SOURCE_DIR}/imgui_widgets.cpp
  # SDL3 + SDL_Renderer backends
  ${imgui_SOURCE_DIR}/backends/imgui_impl_sdl3.cpp
  ${imgui_SOURCE_DIR}/backends/imgui_impl_sdlrenderer3.cpp
)
target_include_directories(imgui_lib
  PUBLIC
    ${imgui_SOURCE_DIR}
    ${imgui_SOURCE_DIR}/backends
)
target_link_libraries(imgui_lib
  PUBLIC
    SDL3::SDL3-static
)

add_executable(simple_raytracer
  src/main.cpp
)

target_link_libraries(simple_raytracer
  PRIVATE
    SDL3::SDL3-static
    imgui_lib
)

# Name build output
set_target_properties(simple_raytracer PROPERTIES
  OUTPUT_NAME "simple_raytracer"
)
