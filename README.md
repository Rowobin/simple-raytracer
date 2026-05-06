> [!NOTE]  
> This repository is still a WIP. Missing features are to be expected.

# simple-raytracer

An open-source raytracing engine built with SDL3 GPU.

## Why

I really like graphics programming, and wanted to write my own raytracer and create pretty scenarios with it.
That's the main reason I created this project.

In addition to that, while I don't think the world needs yet another raytracing tutorial, I wanted to make one anyways!

A lot of the popular raytracing tutorials online use no graphics API at all, and instead make you use your CPU
to generate image files. This approach is perfectly fine for a tutorial. However, I using something like
SDL allows you to write interactive programs, which I think is more fun!

### Why SDL3?

In today's wold, there are many great, feature-rich graphics APIs (OpenGL, DirectX, Vulkan, Metal, etc). However,
writing cross-platform graphics code is still a bit of a challenge:
- **OpenGL** is too old;
- **Vulkan** is too verbose;
- **DirectX** and **Metal** are stuck in the **Microsoft** and **Apple** mines, respectively;
- I could keep going...

I think that, in situations where Vulkan's lower-level features aren't required, SDL3 is probably the best option
for cross-platform graphics applications:
- The new SDL GPU API provides a nice abstraction layer for apps to talk to modern graphics hardware;
- It's supported on all major operating systems and consoles;
- It's easy to learn and set up.

## Features

## How to build

### Native

Building simple-raytracer as a native program is extremely simple. All the dependencies 
are fetched from Github by CMake. As long as you have CMake and a C compiler installed on your machine,
you are good to go.

```bash
git clone https://github.com/Rowobin/simple-raytracer.git
cd simple-raytracer
mkdir build
cd build
cmake -B build-native -S ..
cmake --build build-native
./build-native/simple_raytracer.exe
```

### Emscripten/Webassembly

Building simple-raytracer for the web requires setting up emscripten.

```bash
git clone https://github.com/emscripten-core/emsdk.git
cd emsdk
./emsdk install latest
./emsdk activate latest
source ./emsdk_env.sh
```

Once emscripten has been set up, the process is very similar to native.

```bash
git clone https://github.com/Rowobin/simple-raytracer.git
cd simple-raytracer
mkdir build
cd build
emcmake cmake -B build-web -S ..
cmake --build build-web
emrun build-web/simple-raytracer.html
```

## Chapters

If you want to build your own raytracing engine, I wrote X chapters explaining how I created this one:

## Contributing

## License

This project is licensed using [The Unlicense](https://unlicense.org/).


