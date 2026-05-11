#include <metal_stdlib>
#include <metal_math>
#include <metal_texture>
using namespace metal;

#line 11 "shaders/shaders.slang"
struct FragmentOutput_0
{
    float4 color_0 [[color(0)]];
};


#line 11
struct pixelInput_0
{
    float4 color_1 [[user(_SLANG_ATTR)]];
};


#line 26
[[fragment]] FragmentOutput_0 fragmentMain(pixelInput_0 _S1 [[stage_in]], float4 position_0 [[position]])
{

#line 27
    thread FragmentOutput_0 fragmentOutput_0;

    (&fragmentOutput_0)->color_0 = _S1.color_1;

    return fragmentOutput_0;
}

