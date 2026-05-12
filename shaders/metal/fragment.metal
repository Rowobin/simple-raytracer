#include <metal_stdlib>
#include <metal_math>
#include <metal_texture>
using namespace metal;

#line 11 "shaders.slang"
struct FragmentOutput_0
{
    float4 color_0 [[color(0)]];
};


#line 11
struct pixelInput_0
{
    float4 color_1 [[user(_SLANG_ATTR)]];
};


#line 15
struct Uniforms_0
{
    float time_0;
};


#line 33
[[fragment]] FragmentOutput_0 fragmentMain(pixelInput_0 _S1 [[stage_in]], float4 position_0 [[position]], Uniforms_0 constant* uniforms_0 [[buffer(0)]])
{

#line 34
    thread FragmentOutput_0 fragmentOutput_0;


    (&fragmentOutput_0)->color_0 = float4(_S1.color_1.xyz * float3((sin(uniforms_0->time_0 * 2.0) * 0.5 + 0.5)) , 1.0);

    return fragmentOutput_0;
}

