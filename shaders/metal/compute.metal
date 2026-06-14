#include <metal_stdlib>
#include <metal_math>
#include <metal_texture>
using namespace metal;

#line 44 "./shaders.slang"
float rand_0(float seed_0)
{
    return fract(sin(seed_0 * 12.97999954223632812 + 78.23000335693359375) * 43.54000091552734375);
}


#line 39
struct Ray_0
{
    float3 origin_0;
    float3 direction_0;
};


#line 39
Ray_0 Ray_x24init_0(float3 origin_1, float3 direction_1)
{

#line 39
    thread Ray_0 _S1;
    (&_S1)->origin_0 = origin_1;
    (&_S1)->direction_0 = direction_1;

#line 39
    return _S1;
}


#line 33
struct Sphere_0
{
    float4 center_0;
    float radius_0;
};


#line 49
bool hit_sphere_0(const Sphere_0 thread* sphere_0, const Ray_0 thread* ray_0)
{

#line 50
    float3 oc_0 = sphere_0->center_0.xyz - ray_0->origin_0;

    float b_0 = -2.0 * dot(ray_0->direction_0, oc_0);


    return (b_0 * b_0 - 4.0 * dot(ray_0->direction_0, ray_0->direction_0) * (dot(oc_0, oc_0) - sphere_0->radius_0 * sphere_0->radius_0)) >= 0.0;
}


#line 3
struct UniformData_0
{
    int r_seed_0;
    int img_width_0;
    int img_height_0;
    float aspect_ratio_0;
    float4 camera_position_0;
    float4 camera_look_at_0;
    float4 up_0;
    float focal_length_0;
    float viewport_h_0;
    float viewport_w_0;
    float4 viewport_u_0;
    float4 viewport_v_0;
    float4 pixel_u_0;
    float4 pixel_v_0;
    float4 u_0;
    float4 v_0;
    float4 w_0;
    float4 pixel00_0;
    int sphere_count_0;
    int samples_per_pixel_0;
};


#line 4889 "hlsl.meta.slang"
struct KernelContext_0
{
    UniformData_0 constant* u_data_0;
    Sphere_0 device* spheres_0;
    texture2d<float, access::read_write> out_image_0;
};


#line 58 "./shaders.slang"
float4 ray_color_0(const Ray_0 thread* ray_1, KernelContext_0 thread* kernelContext_0)
{

#line 59
    float3 n_0 = normalize(ray_1->direction_0);

#line 59
    int i_0 = int(0);

    for(;;)
    {

#line 61
        if(i_0 < (kernelContext_0->u_data_0->sphere_count_0))
        {
        }
        else
        {

#line 61
            break;
        }

#line 61
        thread Sphere_0 _S2 = kernelContext_0->spheres_0[i_0];

#line 61
        bool _S3 = hit_sphere_0(&_S2, ray_1);

        if(_S3)
        {

#line 64
            return float4(1.0, 0.0, 0.0, 1.0);
        }

#line 61
        i_0 = i_0 + int(1);

#line 61
    }

#line 68
    float a_0 = 0.5 * (n_0.y + 1.0);
    return float4((1.0 - a_0))  + float4(a_0)  * float4(0.5, 0.69999998807907104, 1.0, 1.0);
}



[[kernel]] void computeMain(uint3 thread_id_0 [[thread_position_in_grid]], UniformData_0 constant* u_data_1 [[buffer(0)]], Sphere_0 device* spheres_1 [[buffer(1)]], texture2d<float, access::read_write> out_image_1 [[texture(0)]])
{

#line 74
    thread KernelContext_0 kernelContext_1;

#line 74
    (&kernelContext_1)->u_data_0 = u_data_1;

#line 74
    (&kernelContext_1)->spheres_0 = spheres_1;

#line 74
    (&kernelContext_1)->out_image_0 = out_image_1;
    float3 _S4 = u_data_1->pixel00_0.xyz;
    float3 _S5 = u_data_1->pixel_u_0.xyz;
    float3 _S6 = u_data_1->pixel_v_0.xyz;

    float3 _S7 = u_data_1->camera_position_0.xyz;

    float4 _S8 = float4(0.0, 0.0, 0.0, 0.0);

#line 81
    int i_1 = int(0);

#line 81
    float4 color_0 = _S8;
    for(;;)
    {

#line 82
        if(i_1 < ((&kernelContext_1)->u_data_0->samples_per_pixel_0))
        {
        }
        else
        {

#line 82
            break;
        }

#line 83
        float _S9 = float(thread_id_0.x);

#line 83
        float _S10 = 0.96700000762939453 * float(i_1);
        float _S11 = float(thread_id_0.y);

#line 84
        thread Ray_0 _S12 = Ray_x24init_0(_S7, _S4 + float3((_S9 + (rand_0(float((&kernelContext_1)->u_data_0->r_seed_0) + _S10 * 2.18799996376037598 + _S9 * 0.00300000002607703) - 0.5)))  * _S5 + float3((_S11 + (rand_0(float((&kernelContext_1)->u_data_0->r_seed_0) + _S10 * 2.11800003051757812 + _S11 + 0.17399999499320984) - 0.5)))  * _S6 - _S7);

#line 84
        float4 _S13 = ray_color_0(&_S12, &kernelContext_1);


        float4 color_1 = color_0 + _S13;

#line 82
        i_1 = i_1 + int(1);

#line 82
        color_0 = color_1;

#line 82
    }

#line 91
    (&kernelContext_1)->out_image_0.write(color_0 / float4(float((&kernelContext_1)->u_data_0->samples_per_pixel_0)) ,uint2(int2(thread_id_0.xy)));
    return;
}

