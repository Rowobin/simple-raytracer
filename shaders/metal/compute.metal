#include <metal_stdlib>
#include <metal_math>
#include <metal_texture>
using namespace metal;

#line 9 "/Users/rowobin/Documents/GitHub/simple-raytracer/shaders/shaders.slang"
struct Sphere_0
{
    float3 center_0;
    float radius_0;
};


#line 9
Sphere_0 Sphere_x24init_0(float3 center_1, float radius_1)
{

#line 9
    thread Sphere_0 _S1;
    (&_S1)->center_0 = center_1;
    (&_S1)->radius_0 = radius_1;

#line 9
    return _S1;
}


#line 34
float rand_0(float seed_0)
{

#line 35
    return fract(sin(seed_0 * 12.97999954223632812 + 78.23000335693359375) * 43.54000091552734375);
}


#line 4
struct Ray_0
{
    float3 origin_0;
    float3 dir_0;
};


#line 4
Ray_0 Ray_x24init_0(float3 origin_1, float3 dir_1)
{

#line 4
    thread Ray_0 _S2;
    (&_S2)->origin_0 = origin_1;
    (&_S2)->dir_0 = dir_1;

#line 4
    return _S2;
}


#line 14
struct HitInfo_0
{
    float t_0;
    float3 p_0;
    float3 normal_0;
    bool front_face_0;
};


#line 14
HitInfo_0 HitInfo_x24init_0(float t_1, float3 p_1, float3 normal_1, bool front_face_1)
{

#line 14
    thread HitInfo_0 _S3;
    (&_S3)->t_0 = t_1;
    (&_S3)->p_0 = p_1;
    (&_S3)->normal_0 = normal_1;
    (&_S3)->front_face_0 = front_face_1;

#line 14
    return _S3;
}


#line 55
bool hit_sphere_0(const Ray_0 thread* ray_0, const Sphere_0 thread* sphere_0, float t_min_0, float t_max_0, HitInfo_0 thread* info_0)
{

#line 55
    float3 _S4 = sphere_0->center_0;

#line 55
    float3 _S5 = ray_0->origin_0;
    float3 oc_0 = sphere_0->center_0 - ray_0->origin_0;

#line 56
    float3 _S6 = ray_0->dir_0;
    float a_0 = dot(ray_0->dir_0, ray_0->dir_0);
    float h_0 = dot(ray_0->dir_0, oc_0);

#line 58
    float _S7 = sphere_0->radius_0;

    float discriminant_0 = h_0 * h_0 - a_0 * (dot(oc_0, oc_0) - sphere_0->radius_0 * sphere_0->radius_0);

    float3 _S8 = float3(0.0, 0.0, 0.0);

#line 62
    *info_0 = HitInfo_x24init_0(0.0, _S8, _S8, false);

    if(discriminant_0 < 0.0)
    {

#line 65
        return false;
    }

    float _S9 = sqrt(discriminant_0);

#line 68
    float t_2 = (h_0 - _S9) / a_0;

#line 68
    bool _S10;
    if(t_2 < t_min_0)
    {

#line 69
        _S10 = true;

#line 69
    }
    else
    {

#line 69
        _S10 = t_max_0 < t_2;

#line 69
    }

#line 69
    float t_3;

#line 69
    if(_S10)
    {

#line 70
        float t_4 = (h_0 + _S9) / a_0;
        if(t_4 < t_min_0)
        {

#line 71
            _S10 = true;

#line 71
        }
        else
        {

#line 71
            _S10 = t_max_0 < t_4;

#line 71
        }

#line 71
        if(_S10)
        {

#line 72
            return false;
        }

#line 72
        t_3 = t_4;

#line 69
    }
    else
    {

#line 69
        t_3 = t_2;

#line 69
    }

#line 76
    info_0->t_0 = t_3;
    float3 _S11 = _S5 + float3(t_3)  * _S6;

#line 77
    info_0->p_0 = _S11;
    float3 outward_normal_0 = (_S11 - _S4) / float3(_S7) ;
    bool _S12 = (dot(_S6, outward_normal_0)) < 0.0;

#line 79
    info_0->front_face_0 = _S12;

#line 79
    float3 _S13;
    if(_S12)
    {

#line 80
        _S13 = outward_normal_0;

#line 80
    }
    else
    {

#line 80
        _S13 = - outward_normal_0;

#line 80
    }

#line 80
    info_0->normal_0 = _S13;

    return true;
}


#line 38
float rand_min_max_0(float seed_1, float min_0, float max_0)
{

#line 39
    return rand_0(seed_1) * (max_0 - min_0) + min_0;
}

float3 rand_unit_vector_0(float seed_2)
{

#line 42
    int n_0 = int(0);

    for(;;)
    {

#line 44
        if(n_0 < int(50))
        {
        }
        else
        {

#line 44
            break;
        }

#line 45
        float _S14 = float(n_0);

#line 45
        float3 p_2 = float3(rand_min_max_0(seed_2 * 1.45000004768371582 + _S14, -1.0, 1.0), rand_min_max_0(seed_2 * 2.8900001049041748 + _S14, -1.0, 1.0), rand_min_max_0(seed_2 * 4.32999992370605469 + _S14, -1.0, 1.0));

        if((length(p_2)) <= 1.0)
        {

#line 48
            return normalize(p_2);
        }

#line 48
        n_0 = n_0 + int(1);

#line 44
    }

#line 52
    return float3(0.0, 0.0, 0.0);
}


#line 27
float gamma_correct_0(float c_0)
{

#line 28
    if(c_0 > 0.0)
    {

#line 29
        return sqrt(c_0);
    }
    return 0.0;
}


#line 21
struct ComputeUniform_0
{
    int w_width_0;
    int w_height_0;
};


#line 4889 "hlsl.meta.slang"
struct KernelContext_0
{
    ComputeUniform_0 constant* computeUniform_0;
    texture2d<float, access::read_write> OutImage_0;
};


#line 126 "/Users/rowobin/Documents/GitHub/simple-raytracer/shaders/shaders.slang"
float4 ray_color_0(const Ray_0 thread* _S15, const array<Sphere_0, int(2)> thread* _S16, int _S17, float _S18)
{

#line 87
    float4 _S19 = float4(1.0, 1.0, 1.0, 1.0);

#line 87
    Ray_0 _S20 = *_S15;

#line 87
    int bounces_0 = int(0);

#line 87
    float4 color_0 = _S19;

    for(;;)
    {

#line 89
        if(bounces_0 < int(50))
        {
        }
        else
        {

#line 89
            break;
        }
        thread HitInfo_0 temp_info_0;

#line 91
        HitInfo_0 info_1;

#line 91
        float closest_0 = 1000.0;

#line 91
        bool hit_anything_0 = false;

#line 91
        int i_0 = int(0);

#line 97
        for(;;)
        {

#line 97
            if(i_0 < _S17)
            {
            }
            else
            {

#line 97
                break;
            }

#line 97
            thread Ray_0 _S21 = _S20;

#line 97
            bool _S22 = hit_sphere_0(&_S21, &(*_S16)[i_0], 0.10000000149011612, closest_0, &temp_info_0);
            if(_S22)
            {

#line 98
                closest_0 = temp_info_0.t_0;

#line 98
                hit_anything_0 = true;

#line 98
                info_1 = temp_info_0;

#line 98
            }

#line 97
            i_0 = i_0 + int(1);

#line 97
        }

#line 97
        float4 _S23;

#line 97
        Ray_0 _S24;

#line 105
        if(hit_anything_0)
        {

#line 105
            _S24 = Ray_x24init_0(info_1.p_0, info_1.normal_0 + rand_unit_vector_0(_S18 + float(bounces_0) * 4.1119999885559082));

#line 105
            _S23 = color_0 * float4(0.5) ;

#line 105
        }
        else
        {



            float a_1 = 0.5 * (normalize(_S20.dir_0).y + 1.0);

#line 111
            color_0 = color_0 * (float4((1.0 - a_1))  + float4(a_1)  * float4(0.5, 0.69999998807907104, 1.0, 1.0));

            break;
        }
        int _S25 = bounces_0 + int(1);

#line 115
        _S20 = _S24;

#line 115
        bounces_0 = _S25;

#line 115
        color_0 = _S23;

#line 89
    }

#line 119
    return float4(color_0.xyz, 1.0);
}



[[kernel]] void computeMain(uint3 dispatchThreadID_0 [[thread_position_in_grid]], ComputeUniform_0 constant* computeUniform_1 [[buffer(0)]], texture2d<float, access::read_write> OutImage_1 [[texture(0)]])
{

#line 124
    thread KernelContext_0 kernelContext_0;

#line 124
    (&kernelContext_0)->computeUniform_0 = computeUniform_1;

#line 124
    (&kernelContext_0)->OutImage_0 = OutImage_1;

    thread array<Sphere_0, int(2)> world_0;
    world_0[int(0)] = Sphere_x24init_0(float3(0.0, 0.0, -1.0), 0.5);
    world_0[int(1)] = Sphere_x24init_0(float3(0.0, -100.5, -1.0), 100.0);

#line 135
    float3 camera_center_0 = float3(0.0, 0.0, 0.0);



    float3 viewport_u_0 = float3(2.0 * (float(computeUniform_1->w_width_0) / float(computeUniform_1->w_height_0)), 0.0, 0.0);
    float3 viewport_v_0 = float3(0.0, -2.0, 0.0);

    float3 pixel_u_0 = viewport_u_0 / float3(float(computeUniform_1->w_width_0)) ;
    float3 pixel_v_0 = viewport_v_0 / float3(float(computeUniform_1->w_height_0)) ;

#line 143
    float3 _S26 = float3(2.0) ;

    float3 _S27 = camera_center_0 - float3(0.0, 0.0, 1.0) - viewport_u_0 / _S26 - viewport_v_0 / _S26 + pixel_u_0 / _S26 + pixel_v_0 / _S26;

    thread float4 color_1 = float4(0.0, 0.0, 0.0, 0.0);

#line 147
    int i_1 = int(0);
    for(;;)
    {

#line 148
        if(i_1 < int(100))
        {
        }
        else
        {

#line 148
            break;
        }

#line 149
        float _S28 = float(dispatchThreadID_0.x);

#line 149
        float _S29 = float(dispatchThreadID_0.y);

#line 149
        float rand_seed_0 = _S28 * 1.97300004959106445 + _S29 * 9.27000045776367188 + float(i_1) * 3.69000005722045898;

#line 149
        thread Ray_0 _S30 = Ray_x24init_0(camera_center_0, _S27 + float3((_S28 + rand_0(rand_seed_0) - 0.5))  * pixel_u_0 + float3((_S29 + rand_0(rand_seed_0 + 3.70000004768371582) - 0.5))  * pixel_v_0);

#line 149
        thread array<Sphere_0, int(2)> _S31 = world_0;

#line 149
        float4 _S32 = ray_color_0(&_S30, &_S31, int(2), rand_seed_0);

#line 158
        color_1 = color_1 + _S32;

#line 148
        i_1 = i_1 + int(1);

#line 148
    }

#line 161
    float4 _S33 = color_1 / float4(100.0) ;

#line 161
    color_1 = _S33;

    color_1.x = gamma_correct_0(_S33.x);
    color_1.y = gamma_correct_0(color_1.y);
    color_1.z = gamma_correct_0(color_1.z);

    color_1.x = clamp(color_1.x, 0.0, 0.99900001287460327);
    color_1.y = clamp(color_1.y, 0.0, 0.99900001287460327);
    color_1.z = clamp(color_1.z, 0.0, 0.99900001287460327);

    (&kernelContext_0)->OutImage_0.write(color_1,uint2(int2(dispatchThreadID_0.xy)));
    return;
}

