#include <metal_stdlib>
#include <metal_math>
#include <metal_texture>
using namespace metal;

#line 4 "/Users/rowobin/Documents/GitHub/simple-raytracer/shaders/shaders.slang"
struct UniformData_0
{
    int img_width_0;
    int img_height_0;
};


#line 4889 "hlsl.meta.slang"
struct KernelContext_0
{
    UniformData_0 constant* u_data_0;
    texture2d<float, access::read_write> out_image_0;
};


#line 12 "/Users/rowobin/Documents/GitHub/simple-raytracer/shaders/shaders.slang"
[[kernel]] void computeMain(uint3 thread_id_0 [[thread_position_in_grid]], UniformData_0 constant* u_data_1 [[buffer(0)]], texture2d<float, access::read_write> out_image_1 [[texture(0)]])
{

#line 12
    thread KernelContext_0 kernelContext_0;

#line 12
    (&kernelContext_0)->u_data_0 = u_data_1;

#line 12
    (&kernelContext_0)->out_image_0 = out_image_1;
    out_image_1.write(float4(float(thread_id_0.x) / float(u_data_1->img_width_0), float(thread_id_0.y) / float(u_data_1->img_height_0), 0.0, 1.0),uint2(int2(thread_id_0.xy)));
    return;
}

