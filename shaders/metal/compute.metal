#include <metal_stdlib>
#include <metal_math>
#include <metal_texture>
using namespace metal;

#line 51 "./shaders.slang"
float rand_0(float seed_0)
{
    return fract(sin(seed_0 * 12.97999954223632812 + 78.23000335693359375) * 43879.5390625);
}


#line 46
struct Ray_0
{
    float3 origin_0;
    float3 direction_0;
};


#line 46
Ray_0 Ray_x24init_0(float3 origin_1, float3 direction_1)
{

#line 46
    thread Ray_0 _S1;
    (&_S1)->origin_0 = origin_1;
    (&_S1)->direction_0 = direction_1;

#line 46
    return _S1;
}


#line 39
struct HitInfo_0
{
    float t_0;
    float3 p_0;
    float3 normal_0;
    bool front_face_0;
};


#line 39
HitInfo_0 HitInfo_x24init_0(float t_1, float3 p_1, float3 normal_1, bool front_face_1)
{

#line 39
    thread HitInfo_0 _S2;
    (&_S2)->t_0 = t_1;
    (&_S2)->p_0 = p_1;
    (&_S2)->normal_0 = normal_1;
    (&_S2)->front_face_0 = front_face_1;

#line 39
    return _S2;
}


#line 33
struct Sphere_0
{
    float4 center_0;
    float radius_0;
};


#line 86
bool hit_sphere_0(const Sphere_0 thread* sphere_0, const Ray_0 thread* ray_0, HitInfo_0 thread* info_0, float t_min_0, float t_max_0)
{

#line 87
    float3 _S3 = sphere_0->center_0.xyz;

#line 87
    float3 _S4 = ray_0->origin_0;

#line 87
    float3 oc_0 = _S3 - ray_0->origin_0;

#line 87
    float3 _S5 = ray_0->direction_0;
    float a_0 = dot(ray_0->direction_0, ray_0->direction_0);
    float b_0 = -2.0 * dot(ray_0->direction_0, oc_0);

#line 89
    float _S6 = sphere_0->radius_0;

    float discriminant_0 = b_0 * b_0 - 4.0 * a_0 * (dot(oc_0, oc_0) - sphere_0->radius_0 * sphere_0->radius_0);

#line 41
    float3 _S7 = float3(0.0) ;

#line 93
    *info_0 = HitInfo_x24init_0(0.0, _S7, _S7, false);

    if(discriminant_0 <= 0.0)
    {

#line 96
        return false;
    }

    float _S8 = - b_0;

#line 99
    float _S9 = sqrt(discriminant_0);

#line 99
    float _S10 = 2.0 * a_0;

#line 99
    float t_2 = (_S8 - _S9) / _S10;

#line 99
    bool _S11;
    if(t_2 <= t_min_0)
    {

#line 100
        _S11 = true;

#line 100
    }
    else
    {

#line 100
        _S11 = t_max_0 <= t_2;

#line 100
    }

#line 100
    float t_3;

#line 100
    if(_S11)
    {

#line 101
        float t_4 = (_S8 + _S9) / _S10;
        if(t_4 <= t_min_0)
        {

#line 102
            _S11 = true;

#line 102
        }
        else
        {

#line 102
            _S11 = t_max_0 <= t_4;

#line 102
        }

#line 102
        if(_S11)
        {

#line 103
            return false;
        }

#line 103
        t_3 = t_4;

#line 100
    }
    else
    {

#line 100
        t_3 = t_2;

#line 100
    }

#line 107
    info_0->t_0 = t_3;
    float3 _S12 = _S4 + float3(t_3)  * _S5;

#line 108
    info_0->p_0 = _S12;
    float3 outwards_normal_0 = (_S12 - _S3) / float3(_S6) ;
    bool _S13 = (dot(_S5, outwards_normal_0)) <= 0.0;

#line 110
    info_0->front_face_0 = _S13;

#line 110
    float3 _S14;
    if(_S13)
    {

#line 111
        _S14 = outwards_normal_0;

#line 111
    }
    else
    {

#line 111
        _S14 = - outwards_normal_0;

#line 111
    }

#line 111
    info_0->normal_0 = _S14;

    return true;
}


#line 56
float rand_range_0(float seed_1, float r_min_0, float r_max_0)
{

#line 57
    return r_min_0 + rand_0(seed_1) * (r_max_0 - r_min_0);
}

float3 rand_unit_vector_0(float seed_2)
{
    float _S15 = seed_2 * 3.49000000953674316;
    float _S16 = seed_2 * 5.01000022888183594;
    float _S17 = seed_2 * 1.87999999523162842;

#line 64
    float3 v_0 = float3(rand_range_0(_S15, -1.0, 1.0), rand_range_0(_S16, -1.0, 1.0), rand_range_0(_S17, -1.0, 1.0));

#line 64
    int i_0 = int(0);

    for(;;)
    {

#line 66
        if(i_0 < int(50))
        {
        }
        else
        {

#line 66
            break;
        }

#line 67
        if((length(v_0)) < 1.0)
        {

#line 68
            return normalize(v_0);
        }

        int _S18 = i_0 + int(1);

#line 71
        float _S19 = float(_S18);

#line 70
        float3 _S20 = float3(rand_range_0(_S15 + _S19, -1.0, 1.0), rand_range_0(_S16 + _S19, -1.0, 1.0), rand_range_0(_S17 + _S19, -1.0, 1.0));

#line 66
        v_0 = _S20;

#line 66
        i_0 = _S18;

#line 66
    }

#line 76
    return float3(0.0, 0.0, 0.0);
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
    float4 v_1;
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


#line 116 "./shaders.slang"
float4 ray_color_0(const Ray_0 thread* ray_1, float seed_3, KernelContext_0 thread* kernelContext_0)
{

#line 117
    float4 _S21 = float4(1.0, 1.0, 1.0, 1.0);

#line 117
    Ray_0 _S22 = *ray_1;

#line 117
    int bounces_0 = int(0);

#line 117
    float4 color_0 = _S21;

    for(;;)
    {

#line 119
        if(bounces_0 < int(100))
        {
        }
        else
        {

#line 119
            break;
        }

#line 120
        thread HitInfo_0 info_1;
        (&info_1)->t_0 = 10000.0;

#line 121
        bool hit_anything_0 = false;

#line 121
        int i_1 = int(0);


        for(;;)
        {

#line 124
            if(i_1 < (kernelContext_0->u_data_0->sphere_count_0))
            {
            }
            else
            {

#line 124
                break;
            }

#line 124
            thread Sphere_0 _S23 = kernelContext_0->spheres_0[i_1];

#line 124
            thread Ray_0 _S24 = _S22;
            thread HitInfo_0 tmp_0;

#line 125
            bool _S25 = hit_sphere_0(&_S23, &_S24, &tmp_0, 0.00100000004749745, (&info_1)->t_0);
            if(_S25)
            {

#line 127
                info_1 = tmp_0;

#line 127
                hit_anything_0 = true;

#line 126
            }

#line 124
            i_1 = i_1 + int(1);

#line 124
        }

#line 124
        Ray_0 _S26;

#line 124
        float4 _S27;

#line 132
        if(hit_anything_0)
        {

#line 132
            _S27 = color_0 * float4(0.69999998807907104, 0.69999998807907104, 0.69999998807907104, 1.0);

#line 132
            _S26 = Ray_x24init_0((&info_1)->p_0, (&info_1)->normal_0 + rand_unit_vector_0(seed_3 + float(bounces_0) * 7.23000001907348633));

#line 132
        }
        else
        {



            float a_1 = 0.5 * (normalize(_S22.direction_0).y + 1.0);

#line 138
            color_0 = color_0 * (float4((1.0 - a_1))  + float4(a_1)  * float4(0.5, 0.69999998807907104, 1.0, 1.0));

            break;
        }

#line 119
        int _S28 = bounces_0 + int(1);

#line 119
        _S22 = _S26;

#line 119
        bounces_0 = _S28;

#line 119
        color_0 = _S27;

#line 119
    }

#line 144
    return color_0;
}


#line 79
float gamma_correct_0(float v_2)
{

#line 80
    if(v_2 >= 0.0)
    {

#line 81
        return sqrt(v_2);
    }
    return v_2;
}


#line 149
[[kernel]] void computeMain(uint3 thread_id_0 [[thread_position_in_grid]], UniformData_0 constant* u_data_1 [[buffer(0)]], Sphere_0 device* spheres_1 [[buffer(1)]], texture2d<float, access::read_write> out_image_1 [[texture(0)]])
{

#line 149
    thread KernelContext_0 kernelContext_1;

#line 149
    (&kernelContext_1)->u_data_0 = u_data_1;

#line 149
    (&kernelContext_1)->spheres_0 = spheres_1;

#line 149
    (&kernelContext_1)->out_image_0 = out_image_1;
    float3 _S29 = u_data_1->pixel00_0.xyz;
    float3 _S30 = u_data_1->pixel_u_0.xyz;
    float3 _S31 = u_data_1->pixel_v_0.xyz;

    float3 _S32 = u_data_1->camera_position_0.xyz;

    thread float4 color_1 = float4(0.0, 0.0, 0.0, 0.0);

#line 156
    int i_2 = int(0);
    for(;;)
    {

#line 157
        if(i_2 < ((&kernelContext_1)->u_data_0->samples_per_pixel_0))
        {
        }
        else
        {

#line 157
            break;
        }

#line 158
        float _S33 = float(thread_id_0.x);

#line 158
        float _S34 = float(i_2);

#line 158
        float _S35 = 0.96700000762939453 * _S34;
        float _S36 = float(thread_id_0.y);


        float _S37 = float((&kernelContext_1)->u_data_0->r_seed_0) + _S33 * 1.21000003814697266 + _S36 * 0.44999998807907104 + _S34 * 7.76999998092651367;

#line 162
        thread Ray_0 _S38 = Ray_x24init_0(_S32, _S29 + float3((_S33 + (rand_0(float((&kernelContext_1)->u_data_0->r_seed_0) + _S35 * 2.18799996376037598 + _S33 * 0.00300000002607703) - 0.5)))  * _S30 + float3((_S36 + (rand_0(float((&kernelContext_1)->u_data_0->r_seed_0) + _S35 * 2.11800003051757812 + _S36 + 0.17399999499320984) - 0.5)))  * _S31 - _S32);

#line 162
        float4 _S39 = ray_color_0(&_S38, _S37, &kernelContext_1);

#line 162
        color_1 = color_1 + _S39;

#line 157
        i_2 = i_2 + int(1);

#line 157
    }

#line 165
    float4 _S40 = color_1 / float4(float((&kernelContext_1)->u_data_0->samples_per_pixel_0)) ;

#line 165
    color_1 = _S40;

    color_1.x = gamma_correct_0(_S40.x);
    color_1.y = gamma_correct_0(color_1.y);
    color_1.z = gamma_correct_0(color_1.z);

    color_1.x = clamp(color_1.x, 0.0, 1.0);
    color_1.y = clamp(color_1.y, 0.0, 1.0);
    color_1.z = clamp(color_1.z, 0.0, 1.0);

    (&kernelContext_1)->out_image_0.write(color_1,uint2(int2(thread_id_0.xy)));
    return;
}

