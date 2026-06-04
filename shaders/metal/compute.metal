#include <metal_stdlib>
#include <metal_math>
#include <metal_texture>
using namespace metal;

#line 15 "/Users/rowobin/Documents/GitHub/simple-raytracer/shaders/shaders.slang"
struct Material_0
{
    int type_0;
    float4 albedo_0;
    float fuzz_0;
    float refraction_index_0;
};


#line 15
Material_0 Material_x24init_0(int type_1, float4 albedo_1, float fuzz_1, float refraction_index_1)
{

#line 15
    thread Material_0 _S1;
    (&_S1)->type_0 = type_1;
    (&_S1)->albedo_0 = albedo_1;
    (&_S1)->fuzz_0 = fuzz_1;
    (&_S1)->refraction_index_0 = refraction_index_1;

#line 15
    return _S1;
}


#line 22
struct Sphere_0
{
    float3 center_0;
    float radius_0;
    Material_0 mat_0;
};


#line 22
Sphere_0 Sphere_x24init_0(float3 center_1, float radius_1, const Material_0 thread* mat_1)
{

#line 22
    thread Sphere_0 _S2;
    (&_S2)->center_0 = center_1;
    (&_S2)->radius_0 = radius_1;
    (&_S2)->mat_0 = *mat_1;

#line 22
    return _S2;
}


#line 1204 "core.meta.slang"
float float_getPi_0()
{

#line 1204
    return 3.14159274101257324;
}


#line 13611 "hlsl.meta.slang"
float radians_0(float x_0)
{

#line 13622
    return x_0 * (float_getPi_0() / 180.0);
}


#line 49 "/Users/rowobin/Documents/GitHub/simple-raytracer/shaders/shaders.slang"
float rand_0(float seed_0)
{

#line 50
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
    thread Ray_0 _S3;
    (&_S3)->origin_0 = origin_1;
    (&_S3)->dir_0 = dir_1;

#line 4
    return _S3;
}


#line 28
struct HitInfo_0
{
    float t_0;
    float3 p_0;
    float3 normal_0;
    bool front_face_0;
    Material_0 mat_2;
};


#line 28
HitInfo_0 HitInfo_x24init_0(float t_1, float3 p_1, float3 normal_1, bool front_face_1, const Material_0 thread* mat_3)
{

#line 28
    thread HitInfo_0 _S4;
    (&_S4)->t_0 = t_1;
    (&_S4)->p_0 = p_1;
    (&_S4)->normal_0 = normal_1;
    (&_S4)->front_face_0 = front_face_1;
    (&_S4)->mat_2 = *mat_3;

#line 28
    return _S4;
}


#line 70
bool hit_sphere_0(const Ray_0 thread* ray_0, const Sphere_0 thread* sphere_0, float t_min_0, float t_max_0, HitInfo_0 thread* info_0)
{

#line 70
    float3 _S5 = sphere_0->center_0;

#line 70
    float3 _S6 = ray_0->origin_0;
    float3 oc_0 = sphere_0->center_0 - ray_0->origin_0;

#line 71
    float3 _S7 = ray_0->dir_0;
    float a_0 = dot(ray_0->dir_0, ray_0->dir_0);
    float h_0 = dot(ray_0->dir_0, oc_0);

#line 73
    float _S8 = sphere_0->radius_0;

    float discriminant_0 = h_0 * h_0 - a_0 * (dot(oc_0, oc_0) - sphere_0->radius_0 * sphere_0->radius_0);

    float3 _S9 = float3(0.0, 0.0, 0.0);

#line 77
    thread Material_0 _S10 = Material_x24init_0(int(0), float4(0.0) , 0.0, 0.0);

#line 77
    HitInfo_0 _S11 = HitInfo_x24init_0(0.0, _S9, _S9, false, &_S10);

#line 77
    *info_0 = _S11;

    if(discriminant_0 < 0.0)
    {

#line 80
        return false;
    }

    float _S12 = sqrt(discriminant_0);

#line 83
    float t_2 = (h_0 - _S12) / a_0;

#line 83
    bool _S13;
    if(t_2 < t_min_0)
    {

#line 84
        _S13 = true;

#line 84
    }
    else
    {

#line 84
        _S13 = t_max_0 < t_2;

#line 84
    }

#line 84
    float t_3;

#line 84
    if(_S13)
    {

#line 85
        float t_4 = (h_0 + _S12) / a_0;
        if(t_4 < t_min_0)
        {

#line 86
            _S13 = true;

#line 86
        }
        else
        {

#line 86
            _S13 = t_max_0 < t_4;

#line 86
        }

#line 86
        if(_S13)
        {

#line 87
            return false;
        }

#line 87
        t_3 = t_4;

#line 84
    }
    else
    {

#line 84
        t_3 = t_2;

#line 84
    }

#line 91
    info_0->t_0 = t_3;
    float3 _S14 = _S6 + float3(t_3)  * _S7;

#line 92
    info_0->p_0 = _S14;
    float3 outward_normal_0 = (_S14 - _S5) / float3(_S8) ;
    bool _S15 = (dot(_S7, outward_normal_0)) < 0.0;

#line 94
    info_0->front_face_0 = _S15;

#line 94
    float3 _S16;
    if(_S15)
    {

#line 95
        _S16 = outward_normal_0;

#line 95
    }
    else
    {

#line 95
        _S16 = - outward_normal_0;

#line 95
    }

#line 95
    info_0->normal_0 = _S16;
    info_0->mat_2 = sphere_0->mat_0;

    return true;
}


#line 53
float rand_min_max_0(float seed_1, float min_0, float max_0)
{

#line 54
    return rand_0(seed_1) * (max_0 - min_0) + min_0;
}

float3 rand_unit_vector_0(float seed_2)
{

#line 57
    int n_0 = int(0);

    for(;;)
    {

#line 59
        if(n_0 < int(50))
        {
        }
        else
        {

#line 59
            break;
        }

#line 60
        float _S17 = float(n_0);

#line 60
        float3 p_2 = float3(rand_min_max_0(seed_2 * 1.45000004768371582 + _S17, -1.0, 1.0), rand_min_max_0(seed_2 * 2.8900001049041748 + _S17, -1.0, 1.0), rand_min_max_0(seed_2 * 4.32999992370605469 + _S17, -1.0, 1.0));

        if((length(p_2)) <= 1.0)
        {

#line 63
            return normalize(p_2);
        }

#line 63
        n_0 = n_0 + int(1);

#line 59
    }

#line 67
    return float3(0.0, 0.0, 0.0);
}


#line 42
float gamma_correct_0(float c_0)
{

#line 43
    if(c_0 > 0.0)
    {

#line 44
        return sqrt(c_0);
    }
    return 0.0;
}


#line 36
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


#line 188 "/Users/rowobin/Documents/GitHub/simple-raytracer/shaders/shaders.slang"
float4 ray_color_0(const Ray_0 thread* _S18, const array<Sphere_0, int(5)> thread* _S19, int _S20, float _S21)
{

#line 103
    float4 _S22 = float4(1.0, 1.0, 1.0, 1.0);

#line 103
    Ray_0 _S23 = *_S18;

#line 103
    int bounces_0 = int(0);

#line 103
    float4 color_0 = _S22;

    for(;;)
    {

#line 105
        if(bounces_0 < int(20))
        {
        }
        else
        {

#line 105
            break;
        }
        thread HitInfo_0 temp_info_0;

#line 107
        HitInfo_0 info_1;

#line 107
        float closest_0 = 1000.0;

#line 107
        bool hit_anything_0 = false;

#line 107
        int i_0 = int(0);

#line 113
        for(;;)
        {

#line 113
            if(i_0 < _S20)
            {
            }
            else
            {

#line 113
                break;
            }

#line 113
            thread Ray_0 _S24 = _S23;

#line 113
            bool _S25 = hit_sphere_0(&_S24, &(*_S19)[i_0], 0.00009999999747379, closest_0, &temp_info_0);
            if(_S25)
            {

#line 114
                closest_0 = temp_info_0.t_0;

#line 114
                hit_anything_0 = true;

#line 114
                info_1 = temp_info_0;

#line 114
            }

#line 113
            i_0 = i_0 + int(1);

#line 113
        }

#line 113
        Ray_0 _S26;

#line 121
        if(hit_anything_0)
        {

#line 106
            HitInfo_0 _S27 = info_1;

#line 106
            float3 direction_0;

#line 123
            switch(info_1.mat_2.type_0)
            {
            case int(0):
                {

#line 106
                    HitInfo_0 _S28 = info_1;

#line 125
                    float3 direction_1 = info_1.normal_0 + rand_unit_vector_0(_S21 + float(bounces_0) * 4.1119999885559082);
                    if((dot(direction_1, direction_1)) < 0.00100000004749745)
                    {

#line 126
                        direction_0 = _S28.normal_0;

#line 126
                    }
                    else
                    {

#line 126
                        direction_0 = direction_1;

#line 126
                    }


                    if((dot(direction_0, _S28.normal_0)) <= 0.0)
                    {

#line 129
                        color_0 = color_0 * float4(0.0, 0.0, 0.0, 1.0);

                        break;
                    }

#line 131
                    color_0 = color_0 * _S27.mat_2.albedo_0;


                    break;
                }
            case int(1):
                {

#line 137
                    float3 direction_2 = normalize(_S23.dir_0 - float3((2.0 * dot(_S23.dir_0, info_1.normal_0)))  * info_1.normal_0) + float3(_S27.mat_2.fuzz_0)  * rand_unit_vector_0(_S21 + float(bounces_0) * 3.11100006103515625 + _S27.mat_2.fuzz_0 * 1.22399997711181641);
                    if((dot(direction_2, info_1.normal_0)) <= 0.0)
                    {

#line 139
                        float4 color_1 = color_0 * float4(0.0, 0.0, 0.0, 1.0);

#line 139
                        direction_0 = direction_2;

#line 139
                        color_0 = color_1;
                        break;
                    }
                    float4 color_2 = color_0 * _S27.mat_2.albedo_0;

#line 142
                    direction_0 = direction_2;

#line 142
                    color_0 = color_2;
                    break;
                }
            case int(2):
                {

#line 143
                    float ri_0;


                    if(info_1.front_face_0)
                    {

#line 146
                        ri_0 = 1.0 / _S27.mat_2.refraction_index_0;

#line 146
                    }
                    else
                    {

#line 146
                        ri_0 = _S27.mat_2.refraction_index_0;

#line 146
                    }
                    float3 unit_vector_0 = normalize(_S23.dir_0);

#line 106
                    HitInfo_0 _S29 = info_1;

#line 148
                    float _S30 = min(dot(- unit_vector_0, info_1.normal_0), 1.0);


                    float r0_0 = (1.0 - ri_0) / (1.0 + ri_0);
                    float r0_1 = r0_0 * r0_0;
                    float r0_2 = r0_1 + (1.0 - r0_1) * pow(1.0 - _S30, 5.0);

#line 153
                    bool _S31;

                    if((sqrt(1.0 - _S30 * _S30) * ri_0) > 1.0)
                    {

#line 155
                        _S31 = true;

#line 155
                    }
                    else
                    {

#line 155
                        _S31 = r0_2 > (rand_0(_S21 + float(bounces_0) * 3.21000003814697266));

#line 155
                    }

#line 155
                    if(_S31)
                    {

#line 155
                        direction_0 = unit_vector_0 - float3((2.0 * dot(unit_vector_0, _S29.normal_0)))  * _S29.normal_0;

#line 155
                    }
                    else
                    {
                        float3 r_out_perp_0 = float3(ri_0)  * (unit_vector_0 + float3(_S30)  * _S29.normal_0);
                        float _S32 = length(r_out_perp_0);

#line 159
                        direction_0 = r_out_perp_0 + float3(- sqrt(abs(1.0 - _S32 * _S32)))  * _S29.normal_0;

#line 155
                    }

#line 162
                    break;
                }
            default:
                {

#line 162
                    break;
                }
            }

#line 162
            _S26 = Ray_x24init_0(info_1.p_0, direction_0);

#line 121
        }
        else
        {

#line 167
            float a_1 = 0.5 * (normalize(_S23.dir_0).y + 1.0);

#line 167
            color_0 = color_0 * (float4((1.0 - a_1))  + float4(a_1)  * float4(0.5, 0.69999998807907104, 1.0, 1.0));

            break;
        }
        int _S33 = bounces_0 + int(1);

#line 171
        _S23 = _S26;

#line 171
        bounces_0 = _S33;

#line 105
    }

#line 174
    return color_0;
}



[[kernel]] void computeMain(uint3 dispatchThreadID_0 [[thread_position_in_grid]], ComputeUniform_0 constant* computeUniform_1 [[buffer(0)]], texture2d<float, access::read_write> OutImage_1 [[texture(0)]])
{

#line 179
    thread KernelContext_0 kernelContext_0;

#line 179
    (&kernelContext_0)->computeUniform_0 = computeUniform_1;

#line 179
    (&kernelContext_0)->OutImage_0 = OutImage_1;



    Material_0 material_right_0 = Material_x24init_0(int(1), float4(0.80000001192092896, 0.60000002384185791, 0.20000000298023224, 1.0), 0.40000000596046448, 0.0);
    Material_0 material_center_0 = Material_x24init_0(int(0), float4(0.10000000149011612, 0.20000000298023224, 0.5, 1.0), 0.0, 0.0);
    float4 _S34 = float4(0.0, 0.0, 0.0, 0.0);

#line 185
    Material_0 material_left_0 = Material_x24init_0(int(2), _S34, 0.0, 1.5);
    Material_0 material_bubble_0 = Material_x24init_0(int(2), _S34, 0.0, 0.66666668653488159);

    thread array<Sphere_0, int(5)> world_0;
    float3 _S35 = float3(0.0, -100.5, -1.0);

#line 189
    thread Material_0 _S36 = Material_x24init_0(int(0), float4(0.80000001192092896, 0.80000001192092896, 0.0, 1.0), 0.0, 0.0);

#line 189
    Sphere_0 _S37 = Sphere_x24init_0(_S35, 100.0, &_S36);

#line 189
    world_0[int(0)] = _S37;
    float3 _S38 = float3(0.0, 0.0, -1.20000004768371582);

#line 190
    thread Material_0 _S39 = material_center_0;

#line 190
    Sphere_0 _S40 = Sphere_x24init_0(_S38, 0.5, &_S39);

#line 190
    world_0[int(1)] = _S40;
    float3 _S41 = float3(-1.0, 0.0, -1.0);

#line 191
    thread Material_0 _S42 = material_left_0;

#line 191
    Sphere_0 _S43 = Sphere_x24init_0(_S41, 0.5, &_S42);

#line 191
    world_0[int(2)] = _S43;

#line 191
    thread Material_0 _S44 = material_bubble_0;

#line 191
    Sphere_0 _S45 = Sphere_x24init_0(_S41, 0.40000000596046448, &_S44);
    world_0[int(3)] = _S45;
    float3 _S46 = float3(1.0, 0.0, -1.0);

#line 193
    thread Material_0 _S47 = material_right_0;

#line 193
    Sphere_0 _S48 = Sphere_x24init_0(_S46, 0.5, &_S47);

#line 193
    world_0[int(4)] = _S48;



    float3 look_from_0 = float3(-2.0, 2.0, 2.0);

#line 202
    float3 _S49 = look_from_0 - float3(0.0, 0.0, -1.0);

#line 202
    float focal_length_0 = length(_S49);


    float viewport_height_0 = 2.0 * tan(radians_0(45.0) / 2.0) * focal_length_0;


    float3 w_0 = normalize(_S49);
    float3 u_0 = normalize(cross(float3(0.0, 1.0, 0.0), w_0));

#line 214
    float3 viewport_u_0 = float3((viewport_height_0 * (float(computeUniform_1->w_width_0) / float(computeUniform_1->w_height_0))))  * u_0;
    float3 viewport_v_0 = float3(- viewport_height_0)  * cross(w_0, u_0);

    float3 pixel_u_0 = viewport_u_0 / float3(float(computeUniform_1->w_width_0)) ;
    float3 pixel_v_0 = viewport_v_0 / float3(float(computeUniform_1->w_height_0)) ;

#line 218
    float3 _S50 = float3(2.0) ;

    float3 _S51 = look_from_0 - float3(focal_length_0)  * w_0 - viewport_u_0 / _S50 - viewport_v_0 / _S50 + pixel_u_0 / _S50 + pixel_v_0 / _S50;

    thread float4 color_3 = _S34;

#line 222
    int i_1 = int(0);
    for(;;)
    {

#line 223
        if(i_1 < int(100))
        {
        }
        else
        {

#line 223
            break;
        }

#line 224
        float _S52 = float(dispatchThreadID_0.x);

#line 224
        float _S53 = float(dispatchThreadID_0.y);

#line 224
        float rand_seed_0 = _S52 * 1.97300004959106445 + _S53 * 9.27000045776367188 + float(i_1) * 3.69000005722045898;

#line 224
        thread Ray_0 _S54 = Ray_x24init_0(look_from_0, _S51 + float3((_S52 + rand_0(rand_seed_0) - 0.5))  * pixel_u_0 + float3((_S53 + rand_0(rand_seed_0 + 3.70000004768371582) - 0.5))  * pixel_v_0 - look_from_0);

#line 224
        thread array<Sphere_0, int(5)> _S55 = world_0;

#line 224
        float4 _S56 = ray_color_0(&_S54, &_S55, int(5), rand_seed_0);

#line 233
        color_3 = color_3 + _S56;

#line 223
        i_1 = i_1 + int(1);

#line 223
    }

#line 236
    float4 _S57 = color_3 / float4(100.0) ;

#line 236
    color_3 = _S57;

    color_3.x = gamma_correct_0(_S57.x);
    color_3.y = gamma_correct_0(color_3.y);
    color_3.z = gamma_correct_0(color_3.z);

    color_3.x = clamp(color_3.x, 0.0, 0.99900001287460327);
    color_3.y = clamp(color_3.y, 0.0, 0.99900001287460327);
    color_3.z = clamp(color_3.z, 0.0, 0.99900001287460327);

    (&kernelContext_0)->OutImage_0.write(color_3,uint2(int2(dispatchThreadID_0.xy)));
    return;
}

