# Building and running simple-raytracer

# On Windows

# mkdir build
# cd build
# cmake -DCMAKE_BUILD_TYPE=Release ..
# cmake --build . --config Released
# .\Release\simple_raytracer.exe

# On MacOS/Linux

# mkdir build
# cd build
# cmake -DCMAKE_BUILD_TYPE=Release ..
# cmake --build . --config Release
# ./simple_raytracer

cmake_minimum_required(VERSION 3.10)

project(SimpleRaytracer VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED True)
set(CMAKE_CXX_EXTENSIONS OFF)

add_executable(simple_raytracer
  src/main.cpp
)

set_target_properties(simple_raytracer PROPERTIES
  OUTPUT_NAME "simple_raytracer"
)
