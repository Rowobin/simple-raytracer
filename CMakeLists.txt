cmake_minimum_required(VERSION 3.10)

project(SimpleRaytracer VERSION 1.0 LANGUAGES CXX)

# Use C++20
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED True)
set(CMAKE_CXX_EXTENSIONS OFF)

# Turn on all compiler warnings
add_compile_options(
  $<$<CXX_COMPILER_ID:GNU,Clang>:-Wall>
  $<$<CXX_COMPILER_ID:GNU,Clang>:-Wextra>
  $<$<CXX_COMPILER_ID:GNU,Clang>:-Wpedantic>
  $<$<CXX_COMPILER_ID:MSVC>:/W4>
)

# Used to fetch external dependencies from github if necessary
include(FetchContent)

# SDL3
find_package(SDL3)
if(NOT SDL3_FOUND)
  message(STATUS "SDL3 not found on system. Fetching from github...")

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
else()
  message(STATUS "SDL3 found on system.")
endif()  

# ImGui
message(STATUS "Fetching ImGui from github...")
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
  ${imgui_SOURCE_DIR}/backends/imgui_impl_sdlgpu3.cpp
)
target_include_directories(imgui_lib
  PUBLIC
    ${imgui_SOURCE_DIR}
    ${imgui_SOURCE_DIR}/backends
)
if(NOT SDL3_FOUND)
  target_link_libraries(imgui_lib
    PUBLIC
    SDL3::SDL3-static
  )
else()
  target_link_libraries(imgui_lib
    PUBLIC
    SDL3::SDL3
  )
endif()

# GLM
find_package(glm QUIET)
if(NOT glm_FOUND)
  FetchContent_Declare(
    glm
    GIT_REPOSITORY	https://github.com/g-truc/glm.git
    GIT_TAG 	1.0.3
  )
  FetchContent_MakeAvailable(glm)
endif()

add_executable(simple_raytracer
  src/main.cpp
)

if(NOT SDL3_FOUND)
  target_link_libraries(simple_raytracer
    PRIVATE
      SDL3::SDL3-static
      imgui_lib
      glm::glm-header-only
  )
else()
  target_link_libraries(simple_raytracer
    PRIVATE
      SDL3::SDL3
      imgui_lib
      glm::glm-header-only
  )
endif()

set_target_properties(simple_raytracer PROPERTIES
  OUTPUT_NAME "simple_raytracer"
)

# copy shaders into build folder
add_custom_target(copy_shaders
  ALL
    COMMAND echo "Compiling shaders..."
    COMMAND bash ${CMAKE_SOURCE_DIR}/shaders/compile_shaders.sh
    COMMAND echo "Copying shaders..."
    COMMAND ${CMAKE_COMMAND} -E copy_directory
      ${CMAKE_SOURCE_DIR}/shaders/spirv 
      $<TARGET_FILE_DIR:simple_raytracer>/shaders/spirv
    COMMAND ${CMAKE_COMMAND} -E copy_directory
      ${CMAKE_SOURCE_DIR}/shaders/metal
      $<TARGET_FILE_DIR:simple_raytracer>/shaders/metal
)
