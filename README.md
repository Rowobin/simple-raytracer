> [!NOTE]  
 This repository is still a WIP. Missing features are to be expected.

# simple-raytracer

An open-source raytracing engine built with SDL3 GPU.

## Why

I really enjoy graphics programming, and I wanted to finally create my own raytracer and create pretty renders
with it.

I decided to use SDL_GPU over other APIs because I think it strikes the perfect balance of being moder modern than
OpenGL while being less verbose than Vulkan.

### Why SDL3?

In today's wold, there are many great, feature-rich graphics APIs (OpenGL, DirectX, Vulkan, Metal, etc). However,
writing cross-platform graphics code is still a bit of a challenge:
- **OpenGL** is too old;
- **Vulkan** is too verbose;
- **DirectX** and **Metal** are stuck in the **Microsoft** and **Apple** mines, respectively;
- I could keep going...

I think that, in situations where Vulkan's lower-level features aren't required, SDL3 is probably the best option
for cross-platform graphics applications:
- The new SDL_GPU API provides a nice abstraction layer for apps to talk to modern graphics hardware;
- It's supported on all major operating systems and consoles;
- It's easy to learn and set up.

## Features

## How to build

To build simple-raytracer, you will need to have CMake and a C/C++ compiler installed.
If those requirements are met, run these commands on your terminal:

```bash
git clone https://github.com/Rowobin/simple-raytracer.git
cd simple-raytracer
mkdir build
cd build
cmake -B build-native -S ..
cmake --build build-native
./build-native/simple_raytracer.exe
```

**Note:** cmake will fetch and compile the SDL3 library if it can't be find it on your machine.

### Building shaders

This program uses Slang for its shaders. In addition to that, there are pre-compiled SPIRV and MSL shaders. If 
you want to compile the shaders yourself, you will need to download the Slang compiler.

```bash
slangc shaders.slang -entry computeMain -stage compute -target spirv -o spirv/compute.spv

slangc shaders.slang -entry computeMain -stage vertex -target metal -o metal/compute.metal
```

## Contributing

If you find any mistakes or think of any improvements to this repository, feel free to send a PR!

## License

This project is licensed using [The Unlicense](https://unlicense.org/).


