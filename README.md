> [!NOTE]  
> This repository is still a WIP. Missing features are to be expected.

# simple-raytracer

An open-source raytracing engine built with SDL3 GPU.

## Why

I really like graphics programming, and wanted to write my own raytracer and create pretty scenarios with it.
That's the main reason I created this project.

In addition to that, while I don't think the world needs yet another raytracing tutorial, I wanted to make one anyways!

A lot of the popular raytracing tutorials online use no graphcis API at all, and instead make you use your CPU
to generate image files. This approach is perfectly fine for a tutorial. That said, I think using something like
SDL allows you to write more interactive programs, which is more fun (and also forces you to learn a few extra
graphics programming concepts)!

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

## Chapters

If you want to build your own raytracing engine, I wrote X chapters explaining how I created this one:

## Contributing

## License

This project is licensed using [The Unlicense](https://unlicense.org/).


