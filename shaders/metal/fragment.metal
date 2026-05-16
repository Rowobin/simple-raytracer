#include <metal_stdlib>
#include <metal_math>
#include <metal_texture>
using namespace metal;

#line 30 "/Users/rowobin/Documents/GitHub/simple-raytracer/shaders/shaders.slang"
float gamma_correct_0(float c_0)
{

#line 31
    if(c_0 <= 0.00313080009073019)
    {

#line 32
        return c_0 * 12.92000007629394531;
    }
    return 1.0549999475479126 * pow(c_0, 0.4166666567325592) - 0.05499999970197678;
}


#line 11
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


#line 38
[[fragment]] FragmentOutput_0 fragmentMain(pixelInput_0 _S1 [[stage_in]], float4 position_0 [[position]], Uniforms_0 constant* uniforms_0 [[buffer(0)]])
{

#line 39
    thread FragmentOutput_0 fragmentOutput_0;


    float4 _S2 = float4(float3((sin(uniforms_0->time_0 * 2.0) * 0.5 + 0.5))  * _S1.color_1.xyz, 1.0);

#line 42
    (&fragmentOutput_0)->color_0 = _S2;
    (&fragmentOutput_0)->color_0.x = gamma_correct_0(_S2.x);
    (&fragmentOutput_0)->color_0.y = gamma_correct_0((&fragmentOutput_0)->color_0.y);
    (&fragmentOutput_0)->color_0.z = gamma_correct_0((&fragmentOutput_0)->color_0.z);

    return fragmentOutput_0;
}

