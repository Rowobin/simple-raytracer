#include <metal_stdlib>
#include <metal_math>
#include <metal_texture>
using namespace metal;

#line 1 "/Users/rowobin/Documents/GitHub/simple-raytracer/shaders/shaders.slang"
struct vertexMain_Result_0
{
    float4 position_0 [[position]];
    float4 color_0 [[user(_SLANG_ATTR)]];
};


#line 1
struct vertexInput_0
{
    float3 position_1 [[attribute(0)]];
    float4 color_1 [[attribute(1)]];
};


#line 6
struct VertexOutput_0
{
    float4 position_2;
    float4 color_2;
};


#line 6
[[vertex]] vertexMain_Result_0 vertexMain(vertexInput_0 _S1 [[stage_in]])
{

#line 22
    thread VertexOutput_0 vertexOutput_0;

    (&vertexOutput_0)->position_2 = float4(_S1.position_1, 1.0);
    (&vertexOutput_0)->color_2 = _S1.color_1;

#line 25
    thread vertexMain_Result_0 _S2;

#line 25
    (&_S2)->position_0 = vertexOutput_0.position_2;

#line 25
    (&_S2)->color_0 = vertexOutput_0.color_2;

#line 25
    return _S2;
}

