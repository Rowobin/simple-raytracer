#include <metal_stdlib>
#include <metal_math>
#include <metal_texture>
using namespace metal;

#line 4 "/Users/rowobin/Documents/GitHub/simple-raytracer/shaders/shaders.slang"
struct ComputeUniform_0
{
    int wWidth_0;
    int wHeight_0;
};


#line 4889 "hlsl.meta.slang"
struct KernelContext_0
{
    ComputeUniform_0 constant* computeUniform_0;
    texture2d<float, access::read_write> OutImage_0;
};


#line 12 "/Users/rowobin/Documents/GitHub/simple-raytracer/shaders/shaders.slang"
[[kernel]] void computeMain(uint3 dispatchThreadID_0 [[thread_position_in_grid]], ComputeUniform_0 constant* computeUniform_1 [[buffer(0)]], texture2d<float, access::read_write> OutImage_1 [[texture(0)]])
{

#line 12
    thread KernelContext_0 kernelContext_0;

#line 12
    (&kernelContext_0)->computeUniform_0 = computeUniform_1;

#line 12
    (&kernelContext_0)->OutImage_0 = OutImage_1;
    float u_0 = float(dispatchThreadID_0.x) / float(computeUniform_1->wWidth_0);
    if(u_0 > 0.75)
    {

#line 15
        (&kernelContext_0)->OutImage_0.write(float4(1.0, 0.0, 0.0, 1.0),uint2(int2(dispatchThreadID_0.xy)));

#line 14
    }
    else
    {

#line 16
        if(u_0 > 0.5)
        {

#line 17
            (&kernelContext_0)->OutImage_0.write(float4(0.0, 1.0, 0.0, 1.0),uint2(int2(dispatchThreadID_0.xy)));

#line 16
        }
        else
        {

#line 18
            if(u_0 > 0.25)
            {

#line 19
                (&kernelContext_0)->OutImage_0.write(float4(0.0, 0.0, 1.0, 1.0),uint2(int2(dispatchThreadID_0.xy)));

#line 18
            }
            else
            {
                (&kernelContext_0)->OutImage_0.write(float4(0.0, 0.0, 0.0, 1.0),uint2(int2(dispatchThreadID_0.xy)));

#line 18
            }

#line 16
        }

#line 14
    }

#line 23
    return;
}

