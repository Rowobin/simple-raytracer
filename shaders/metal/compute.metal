#include <metal_stdlib>
#include <metal_math>
#include <metal_texture>
using namespace metal;

#line 4 "/Users/rowobin/Documents/GitHub/simple-raytracer/shaders/shaders.slang"
struct Ray_0
{
    float3 origin_0;
    float3 dir_0;
};


#line 4
Ray_0 Ray_x24init_0(float3 origin_1, float3 dir_1)
{

#line 4
    thread Ray_0 _S1;
    (&_S1)->origin_0 = origin_1;
    (&_S1)->dir_0 = dir_1;

#line 4
    return _S1;
}


#line 15
bool hit_sphere_0(float3 center_0, float radius_0, const Ray_0 thread* ray_0)
{

#line 16
    float3 oc_0 = center_0 - ray_0->origin_0;

    float b_0 = -2.0 * dot(ray_0->dir_0, oc_0);


    return (b_0 * b_0 - 4.0 * dot(ray_0->dir_0, ray_0->dir_0) * (dot(oc_0, oc_0) - radius_0 * radius_0)) >= 0.0;
}

float4 ray_color_0(const Ray_0 thread* ray_1)
{

#line 24
    bool _S2 = hit_sphere_0(float3(0.0, 0.0, -1.0), 0.5, ray_1);
    if(_S2)
    {

#line 26
        return float4(1.0, 0.0, 0.0, 1.0);
    }

    float a_0 = 0.5 * (normalize(ray_1->dir_0).y + 1.0);
    return float4((1.0 - a_0))  + float4(a_0)  * float4(0.5, 0.69999998807907104, 1.0, 1.0);
}


#line 9
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


#line 35 "/Users/rowobin/Documents/GitHub/simple-raytracer/shaders/shaders.slang"
[[kernel]] void computeMain(uint3 dispatchThreadID_0 [[thread_position_in_grid]], ComputeUniform_0 constant* computeUniform_1 [[buffer(0)]], texture2d<float, access::read_write> OutImage_1 [[texture(0)]])
{

#line 35
    thread KernelContext_0 kernelContext_0;

#line 35
    (&kernelContext_0)->computeUniform_0 = computeUniform_1;

#line 35
    (&kernelContext_0)->OutImage_0 = OutImage_1;

#line 41
    float3 camera_center_0 = float3(0.0, 0.0, 0.0);


    float3 viewport_u_0 = float3(2.0 * (float(computeUniform_1->wWidth_0) / float(computeUniform_1->wHeight_0)), 0.0, 0.0);
    float3 viewport_v_0 = float3(0.0, -2.0, 0.0);

    float3 pixel_u_0 = viewport_u_0 / float3(float(computeUniform_1->wWidth_0)) ;
    float3 pixel_v_0 = viewport_v_0 / float3(float(computeUniform_1->wHeight_0)) ;

#line 48
    float3 _S3 = float3(2.0) ;

#line 58
    uint2 _S4 = uint2(int2(dispatchThreadID_0.xy));

#line 58
    thread Ray_0 _S5 = Ray_x24init_0(camera_center_0, camera_center_0 - (camera_center_0 - float3(0.0, 0.0, 1.0) - viewport_u_0 / _S3 - viewport_v_0 / _S3 + pixel_u_0 / _S3 + pixel_v_0 / _S3 + float3(float(dispatchThreadID_0.x))  * pixel_u_0 + float3(float(dispatchThreadID_0.y))  * pixel_v_0));

#line 58
    float4 _S6 = ray_color_0(&_S5);

#line 58
    OutImage_1.write(_S6,_S4);
    return;
}

