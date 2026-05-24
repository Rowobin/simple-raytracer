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


#line 27
bool hitSphere_0(const Ray_0 thread* ray_0, const Sphere_0 thread* sphere_0, float t_min_0, float t_max_0, HitInfo_0 thread* info_0)
{

#line 27
    float3 _S4 = sphere_0->center_0;

#line 27
    float3 _S5 = ray_0->origin_0;
    float3 oc_0 = sphere_0->center_0 - ray_0->origin_0;

#line 28
    float3 _S6 = ray_0->dir_0;
    float a_0 = dot(ray_0->dir_0, ray_0->dir_0);
    float h_0 = dot(ray_0->dir_0, oc_0);

#line 30
    float _S7 = sphere_0->radius_0;

    float discriminant_0 = h_0 * h_0 - a_0 * (dot(oc_0, oc_0) - sphere_0->radius_0 * sphere_0->radius_0);

    float3 _S8 = float3(0.0, 0.0, 0.0);

#line 34
    *info_0 = HitInfo_x24init_0(0.0, _S8, _S8, false);

    if(discriminant_0 < 0.0)
    {

#line 37
        return false;
    }

    float _S9 = sqrt(discriminant_0);

#line 40
    float t_2 = (h_0 - _S9) / a_0;

#line 40
    bool _S10;
    if(t_2 < t_min_0)
    {

#line 41
        _S10 = true;

#line 41
    }
    else
    {

#line 41
        _S10 = t_max_0 < t_2;

#line 41
    }

#line 41
    float t_3;

#line 41
    if(_S10)
    {

#line 42
        float t_4 = (h_0 + _S9) / a_0;
        if(t_4 < t_min_0)
        {

#line 43
            _S10 = true;

#line 43
        }
        else
        {

#line 43
            _S10 = t_max_0 < t_4;

#line 43
        }

#line 43
        if(_S10)
        {

#line 44
            return false;
        }

#line 44
        t_3 = t_4;

#line 41
    }
    else
    {

#line 41
        t_3 = t_2;

#line 41
    }

#line 48
    info_0->t_0 = t_3;
    float3 _S11 = _S5 + float3(t_3)  * _S6;

#line 49
    info_0->p_0 = _S11;
    float3 outward_normal_0 = (_S11 - _S4) / float3(_S7) ;
    bool _S12 = (dot(_S6, outward_normal_0)) < 0.0;

#line 51
    info_0->front_face_0 = _S12;

#line 51
    float3 _S13;
    if(_S12)
    {

#line 52
        _S13 = outward_normal_0;

#line 52
    }
    else
    {

#line 52
        _S13 = - outward_normal_0;

#line 52
    }

#line 52
    info_0->normal_0 = _S13;

    return true;
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


#line 2520 "core.meta.slang"
float4 ray_color_0(const Ray_0 thread* _S14, const array<Sphere_0, int(2)> thread* _S15, int _S16)
{

#line 60 "/Users/rowobin/Documents/GitHub/simple-raytracer/shaders/shaders.slang"
    thread HitInfo_0 temp_info_0;

#line 60
    HitInfo_0 info_1;

#line 60
    float closest_0 = 1000.0;

#line 60
    bool hit_anything_0 = false;

#line 60
    int i_0 = int(0);

#line 66
    for(;;)
    {

#line 66
        if(i_0 < _S16)
        {
        }
        else
        {

#line 66
            break;
        }

#line 66
        bool _S17 = hitSphere_0(_S14, &(*_S15)[i_0], 0.0, closest_0, &temp_info_0);
        if(_S17)
        {

#line 67
            closest_0 = temp_info_0.t_0;

#line 67
            hit_anything_0 = true;

#line 67
            info_1 = temp_info_0;

#line 67
        }

#line 66
        i_0 = i_0 + int(1);

#line 66
    }

#line 74
    if(hit_anything_0)
    {

#line 75
        return float4(0.5)  * (float4(info_1.normal_0, 0.0) + float4(1.0, 1.0, 1.0, 2.0));
    }


    float a_1 = 0.5 * (normalize(_S14->dir_0).y + 1.0);
    return float4((1.0 - a_1))  + float4(a_1)  * float4(0.5, 0.69999998807907104, 1.0, 1.0);
}



[[kernel]] void computeMain(uint3 dispatchThreadID_0 [[thread_position_in_grid]], ComputeUniform_0 constant* computeUniform_1 [[buffer(0)]], texture2d<float, access::read_write> OutImage_1 [[texture(0)]])
{

#line 85
    thread KernelContext_0 kernelContext_0;

#line 85
    (&kernelContext_0)->computeUniform_0 = computeUniform_1;

#line 85
    (&kernelContext_0)->OutImage_0 = OutImage_1;

#line 91
    float3 camera_center_0 = float3(0.0, 0.0, 0.0);


    float3 viewport_u_0 = float3(2.0 * (float(computeUniform_1->w_width_0) / float(computeUniform_1->w_height_0)), 0.0, 0.0);
    float3 viewport_v_0 = float3(0.0, -2.0, 0.0);

    float3 pixel_u_0 = viewport_u_0 / float3(float(computeUniform_1->w_width_0)) ;
    float3 pixel_v_0 = viewport_v_0 / float3(float(computeUniform_1->w_height_0)) ;

#line 98
    float3 _S18 = float3(2.0) ;

#line 103
    float3 pixel_center_0 = camera_center_0 - float3(0.0, 0.0, 1.0) - viewport_u_0 / _S18 - viewport_v_0 / _S18 + pixel_u_0 / _S18 + pixel_v_0 / _S18 + float3(float(dispatchThreadID_0.x))  * pixel_u_0 + float3(float(dispatchThreadID_0.y))  * pixel_v_0;



    thread array<Sphere_0, int(2)> world_0;
    world_0[int(0)] = Sphere_x24init_0(float3(0.0, 0.0, -1.0), 0.5);
    world_0[int(1)] = Sphere_x24init_0(float3(0.0, -100.5, -1.0), 100.0);



    uint2 _S19 = uint2(int2(dispatchThreadID_0.xy));

#line 113
    thread Ray_0 _S20 = Ray_x24init_0(camera_center_0, pixel_center_0);

#line 113
    thread array<Sphere_0, int(2)> _S21 = world_0;

#line 113
    float4 _S22 = ray_color_0(&_S20, &_S21, int(2));

#line 113
    OutImage_1.write(_S22,_S19);
    return;
}

