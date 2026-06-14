#include <metal_stdlib>
#include <metal_math>
#include <metal_texture>
using namespace metal;

#line 41 "/Users/rowobin/Documents/GitHub/simple-raytracer/shaders/shaders.slang"
float rand_0(float seed_0)
{

#line 42
    return fract(sin(seed_0 * 12.97999954223632812 + 78.23000335693359375) * 43.54000091552734375);
}


#line 36
struct Ray_0
{
    float3 origin_0;
    float3 direction_0;
};


#line 36
Ray_0 Ray_x24init_0(float3 origin_1, float3 direction_1)
{

#line 36
    thread Ray_0 _S1;
    (&_S1)->origin_0 = origin_1;
    (&_S1)->direction_0 = direction_1;

#line 36
    return _S1;
}


#line 30
struct Sphere_0
{
    float3 center_0;
    float radius_0;
};


#line 45
bool hit_sphere_0(const Sphere_0 thread* sphere_0, const Ray_0 thread* ray_0)
{

#line 46
    float3 oc_0 = sphere_0->center_0 - ray_0->origin_0;

    float b_0 = -2.0 * dot(ray_0->direction_0, oc_0);


    return (b_0 * b_0 - 4.0 * dot(ray_0->direction_0, ray_0->direction_0) * (dot(oc_0, oc_0) - sphere_0->radius_0 * sphere_0->radius_0)) >= 0.0;
}


#line 4
struct UniformData_0
{
    float r_seed_0;
    int img_width_0;
    int img_height_0;
    float aspect_ratio_0;
    float3 camera_position_0;
    float3 camera_look_at_0;
    float3 up_0;
    float focal_length_0;
    int samples_per_pixel_0;
    float3 u_0;
    float3 v_0;
    float3 w_0;
    float3 viewport_u_0;
    float3 viewport_v_0;
    float3 pixel_u_0;
    float3 pixel_v_0;
    float3 pixel00_0;
    int sphere_count_0;
};


#line 4889 "hlsl.meta.slang"
struct KernelContext_0
{
    UniformData_0 constant* u_data_0;
    Sphere_0 device* spheres_0;
    texture2d<float, access::read_write> out_image_0;
};


#line 54 "/Users/rowobin/Documents/GitHub/simple-raytracer/shaders/shaders.slang"
float4 ray_color_0(const Ray_0 thread* ray_1, KernelContext_0 thread* kernelContext_0)
{

#line 55
    float3 norm_0 = normalize(ray_1->direction_0);

#line 55
    int i_0 = int(0);

    for(;;)
    {

#line 57
        if(i_0 < (kernelContext_0->u_data_0->sphere_count_0))
        {
        }
        else
        {

#line 57
            break;
        }

#line 57
        thread Sphere_0 _S2 = kernelContext_0->spheres_0[i_0];

#line 57
        bool _S3 = hit_sphere_0(&_S2, ray_1);

        if(_S3)
        {

#line 60
            return float4(1.0, 0.0, 0.0, 1.0);
        }

#line 57
        i_0 = i_0 + int(1);

#line 57
    }

#line 64
    float a_0 = 0.5 * (norm_0.y + 1.0);
    return float4((1.0 - a_0))  + float4(a_0)  * float4(0.5, 0.69999998807907104, 1.0, 1.0);
}



[[kernel]] void computeMain(uint3 thread_id_0 [[thread_position_in_grid]], UniformData_0 constant* u_data_1 [[buffer(0)]], Sphere_0 device* spheres_1 [[buffer(1)]], texture2d<float, access::read_write> out_image_1 [[texture(0)]])
{

#line 70
    thread KernelContext_0 kernelContext_1;

#line 70
    (&kernelContext_1)->u_data_0 = u_data_1;

#line 70
    (&kernelContext_1)->spheres_0 = spheres_1;

#line 70
    (&kernelContext_1)->out_image_0 = out_image_1;
    float4 _S4 = float4(0.0, 0.0, 0.0, 0.0);

#line 71
    int i_1 = int(0);

#line 71
    float4 color_0 = _S4;
    for(;;)
    {

#line 72
        if(i_1 < ((&kernelContext_1)->u_data_0->samples_per_pixel_0))
        {
        }
        else
        {

#line 72
            break;
        }

#line 73
        float _S5 = float(thread_id_0.x);

#line 73
        float _S6 = 0.96700000762939453 * float(i_1);
        float _S7 = float(thread_id_0.y);

#line 74
        thread Ray_0 _S8 = Ray_x24init_0((&kernelContext_1)->u_data_0->camera_position_0, (&kernelContext_1)->u_data_0->pixel00_0 + float3((_S5 + (rand_0((&kernelContext_1)->u_data_0->r_seed_0 + _S6 * 2.18799996376037598 + _S5 * 0.00300000002607703) - 0.5)))  * (&kernelContext_1)->u_data_0->pixel_u_0 + float3((_S7 + (rand_0((&kernelContext_1)->u_data_0->r_seed_0 + _S6 * 2.11800003051757812 + _S7 + 0.17399999499320984) - 0.5)))  * (&kernelContext_1)->u_data_0->pixel_v_0 - (&kernelContext_1)->u_data_0->camera_position_0);

#line 74
        float4 _S9 = ray_color_0(&_S8, &kernelContext_1);


        float4 color_1 = color_0 + _S9;

#line 72
        i_1 = i_1 + int(1);

#line 72
        color_0 = color_1;

#line 72
    }

#line 80
    (&kernelContext_1)->out_image_0.write(color_0 / float4(float((&kernelContext_1)->u_data_0->samples_per_pixel_0)) ,uint2(int2(thread_id_0.xy)));
    return;
}

