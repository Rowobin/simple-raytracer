
> [!NOTE]  
 This repository is still a WIP. Missing features are to be expected.

# simple-raytracer
An open-source raytracing engine built with SDL_GPU.

## Why
I really enjoy graphics programming, and I wanted to finally create my own raytracer and create cool renders with it.
### Why SDL3?
In today's wold, there are many great, feature-rich graphics APIs (OpenGL, DirectX, Vulkan, Metal, etc). However, writing cross-platform graphics code is still a bit of a challenge:
- **OpenGL** is too old;
- **Vulkan** is too verbose;
- **DirectX** and **Metal** are stuck in the **Microsoft** and **Apple** mines, respectively;
- I could keep going...

I think that, in situations where Vulkan's lower-level features aren't required, SDL3 is probably the best option for cross-platform graphics applications:
- The new SDL_GPU API provides a nice abstraction layer for apps to talk to modern graphics hardware;
- It's supported on all major operating systems and consoles;
- It's easy to learn and set up.
## Features
To-Do
## How to build
### Dependencies
I tried to keep dependencies on this project to a minimum. Here's what you need to have on your machine in other to compile simple-raytracer:
- a C++ compiler
- CMake
- slangc (for compiling shaders)
- SDL3 (optional)

**Note 1:** If SDL3 is not installed in your machine, CMake will fetch it from github. ImGui and GML are always fetched from github.

**Note 2:** If you don't have slangc installed on your machine, I would recommend installing the [VulkanSDK](https://vulkan.lunarg.com/sdk/home.

### Building
Once all dependencies are installed, run these commands on your terminal:
```bash
git clone https://github.com/Rowobin/simple-raytracer.git
cd simple-raytracer
mkdir build
cd build
cmake -B build-native -S ..
cmake --build build-native
./build-native/simple_raytracer.exe
```
### Building shaders
This program uses Slang for its shaders. In addition to that, there are pre-compiled SPIRV and MSL shaders. To compile the shaders yourself, you will need to download the slangc compiler.

```bash
slangc shaders.slang -entry computeMain -stage compute -target spirv -o spirv/compute.spv

slangc shaders.slang -entry computeMain -stage vertex -target metal -o metal/compute.metal
```

## Contributing

If you find any mistakes or think of any improvements to this repository, feel free to send a PR!

## License

This project is licensed using [The Unlicense](https://unlicense.org/).

