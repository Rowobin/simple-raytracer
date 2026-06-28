#include <metal_stdlib>
#include <metal_math>
#include <metal_texture>
using namespace metal;

#line 76 "./shaders.slang"
float rand_0(float seed_0)
{
    return fract(sin(seed_0 * 12.97999954223632812 + 78.23000335693359375) * 43879.5390625);
}

float rand_range_0(float seed_1, float r_min_0, float r_max_0)
{

#line 82
    return r_min_0 + rand_0(seed_1) * (r_max_0 - r_min_0);
}


#line 104
float3 rand_vector_2_0(float seed_2)
{
    float _S1 = seed_2 * 4.3899998664855957;
    float _S2 = seed_2 * 5.01000022888183594;

#line 107
    float3 v_0 = float3(rand_range_0(_S1, -1.0, 1.0), rand_range_0(_S2, -1.0, 1.0), 0.0);

#line 107
    int i_0 = int(0);


    for(;;)
    {

#line 110
        if(i_0 < int(10))
        {
        }
        else
        {

#line 110
            break;
        }

#line 111
        if((length(v_0)) <= 1.0)
        {

#line 112
            return v_0;
        }

        float _S3 = float(i_0) * 2.5559999942779541;

#line 114
        float3 _S4 = float3(rand_range_0(_S1 + _S3, -1.0, 1.0), rand_range_0(_S2 + _S3, -1.0, 1.0), 0.0);

#line 110
        int _S5 = i_0 + int(1);

#line 110
        v_0 = _S4;

#line 110
        i_0 = _S5;

#line 110
    }

#line 120
    return float3(0.0, 0.0, 0.0);
}


#line 71
struct Ray_0
{
    float3 origin_0;
    float3 direction_0;
};


#line 71
Ray_0 Ray_x24init_0(float3 origin_1, float3 direction_1)
{

#line 71
    thread Ray_0 _S6;
    (&_S6)->origin_0 = origin_1;
    (&_S6)->direction_0 = direction_1;

#line 71
    return _S6;
}


#line 49
struct Material_0
{
    int type_0;
    float4 albedo_0;
    float fuzz_0;
    float refraction_index_0;
};


#line 49
Material_0 Material_x24init_0(int type_1, float4 albedo_1, float fuzz_1, float refraction_index_1)
{

#line 49
    thread Material_0 _S7;
    (&_S7)->type_0 = type_1;
    (&_S7)->albedo_0 = albedo_1;
    (&_S7)->fuzz_0 = fuzz_1;
    (&_S7)->refraction_index_0 = refraction_index_1;

#line 49
    return _S7;
}


#line 63
struct HitInfo_0
{
    float t_0;
    float3 p_0;
    float3 normal_0;
    bool front_face_0;
    Material_0 mat_0;
};


#line 63
HitInfo_0 HitInfo_x24init_0(float t_1, float3 p_1, float3 normal_1, bool front_face_1, const Material_0 thread* mat_1)
{

#line 63
    thread HitInfo_0 _S8;
    (&_S8)->t_0 = t_1;
    (&_S8)->p_0 = p_1;
    (&_S8)->normal_0 = normal_1;
    (&_S8)->front_face_0 = front_face_1;
    (&_S8)->mat_0 = *mat_1;

#line 63
    return _S8;
}


#line 56
struct Sphere_0
{
    float4 center_0;
    float radius_0;
    Material_0 material_0;
};


#line 130
bool hit_sphere_0(const Sphere_0 thread* sphere_0, const Ray_0 thread* ray_0, HitInfo_0 thread* info_0, float t_min_0, float t_max_0)
{

#line 131
    float3 _S9 = sphere_0->center_0.xyz;

#line 131
    float3 _S10 = ray_0->origin_0;

#line 131
    float3 oc_0 = _S9 - ray_0->origin_0;

#line 131
    float3 _S11 = ray_0->direction_0;
    float a_0 = dot(ray_0->direction_0, ray_0->direction_0);
    float b_0 = -2.0 * dot(ray_0->direction_0, oc_0);

#line 133
    float _S12 = sphere_0->radius_0;

    float discriminant_0 = b_0 * b_0 - 4.0 * a_0 * (dot(oc_0, oc_0) - sphere_0->radius_0 * sphere_0->radius_0);

#line 65
    float3 _S13 = float3(0.0) ;

#line 65
    thread Material_0 _S14 = Material_x24init_0(int(0), float4(0.0) , 0.0, 0.0);

#line 65
    HitInfo_0 _S15 = HitInfo_x24init_0(0.0, _S13, _S13, false, &_S14);

#line 137
    *info_0 = _S15;

    if(discriminant_0 <= 0.0)
    {

#line 140
        return false;
    }

    float _S16 = - b_0;

#line 143
    float _S17 = sqrt(discriminant_0);

#line 143
    float _S18 = 2.0 * a_0;

#line 143
    float t_2 = (_S16 - _S17) / _S18;

#line 143
    bool _S19;
    if(t_2 <= t_min_0)
    {

#line 144
        _S19 = true;

#line 144
    }
    else
    {

#line 144
        _S19 = t_max_0 <= t_2;

#line 144
    }

#line 144
    float t_3;

#line 144
    if(_S19)
    {

#line 145
        float t_4 = (_S16 + _S17) / _S18;
        if(t_4 <= t_min_0)
        {

#line 146
            _S19 = true;

#line 146
        }
        else
        {

#line 146
            _S19 = t_max_0 <= t_4;

#line 146
        }

#line 146
        if(_S19)
        {

#line 147
            return false;
        }

#line 147
        t_3 = t_4;

#line 144
    }
    else
    {

#line 144
        t_3 = t_2;

#line 144
    }

#line 151
    info_0->mat_0 = sphere_0->material_0;
    info_0->t_0 = t_3;
    float3 _S20 = _S10 + float3(t_3)  * _S11;

#line 153
    info_0->p_0 = _S20;
    float3 outwards_normal_0 = (_S20 - _S9) / float3(_S12) ;
    bool _S21 = (dot(_S11, outwards_normal_0)) <= 0.0;

#line 155
    info_0->front_face_0 = _S21;

#line 155
    float3 _S22;
    if(_S21)
    {

#line 156
        _S22 = outwards_normal_0;

#line 156
    }
    else
    {

#line 156
        _S22 = - outwards_normal_0;

#line 156
    }

#line 156
    info_0->normal_0 = _S22;

    return true;
}


#line 85
float3 rand_vector_3_0(float seed_3)
{
    float _S23 = seed_3 * 3.49000000953674316;
    float _S24 = seed_3 * 5.01000022888183594;
    float _S25 = seed_3 * 1.87999999523162842;

#line 89
    float3 v_1 = float3(rand_range_0(_S23, -1.0, 1.0), rand_range_0(_S24, -1.0, 1.0), rand_range_0(_S25, -1.0, 1.0));

#line 89
    int i_1 = int(0);

    for(;;)
    {

#line 91
        if(i_1 < int(10))
        {
        }
        else
        {

#line 91
            break;
        }

#line 92
        if((length(v_1)) <= 1.0)
        {

#line 93
            return v_1;
        }

        float _S26 = float(i_1) * 2.5559999942779541;

#line 95
        float3 _S27 = float3(rand_range_0(_S23 + _S26, -1.0, 1.0), rand_range_0(_S24 + _S26, -1.0, 1.0), rand_range_0(_S25 + _S26, -1.0, 1.0));

#line 91
        int _S28 = i_1 + int(1);

#line 91
        v_1 = _S27;

#line 91
        i_1 = _S28;

#line 91
    }

#line 101
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
    float defocus_angle_0;
    float focus_dist_0;
    float fov_0;
    float viewport_h_0;
    float viewport_w_0;
    float4 viewport_u_0;
    float4 viewport_v_0;
    float4 pixel_u_0;
    float4 pixel_v_0;
    float4 u_0;
    float4 v_2;
    float4 w_0;
    float4 defocus_disk_u_0;
    float4 defocus_disk_v_0;
    float4 pixel00_0;
    int sphere_count_0;
    int samples_per_pixel_0;
    float t_min_1;
    float t_max_1;
    int max_bounces_0;
};


#line 4889 "hlsl.meta.slang"
struct KernelContext_0
{
    UniformData_0 constant* u_data_0;
    Sphere_0 device* spheres_0;
    texture2d<float, access::read_write> out_image_0;
};


#line 161 "./shaders.slang"
float4 ray_color_0(const Ray_0 thread* ray_1, float seed_4, KernelContext_0 thread* kernelContext_0)
{

#line 162
    float4 _S29 = float4(1.0, 1.0, 1.0, 1.0);

#line 162
    Ray_0 _S30 = *ray_1;

#line 162
    int bounces_0 = int(0);

#line 162
    float4 color_0 = _S29;

    for(;;)
    {

#line 164
        if(bounces_0 < (kernelContext_0->u_data_0->max_bounces_0))
        {
        }
        else
        {

#line 164
            break;
        }

#line 165
        thread HitInfo_0 info_1;
        (&info_1)->t_0 = kernelContext_0->u_data_0->t_max_1;

#line 166
        bool hit_anything_0 = false;

#line 166
        int i_2 = int(0);


        for(;;)
        {

#line 169
            if(i_2 < (kernelContext_0->u_data_0->sphere_count_0))
            {
            }
            else
            {

#line 169
                break;
            }
            float _S31 = kernelContext_0->u_data_0->t_min_1;

#line 171
            thread Sphere_0 _S32 = kernelContext_0->spheres_0[i_2];

#line 171
            thread Ray_0 _S33 = _S30;

#line 170
            thread HitInfo_0 tmp_0;

#line 170
            bool _S34 = hit_sphere_0(&_S32, &_S33, &tmp_0, _S31, (&info_1)->t_0);
            if(_S34)
            {

#line 172
                info_1 = tmp_0;

#line 172
                hit_anything_0 = true;

#line 171
            }

#line 169
            i_2 = i_2 + int(1);

#line 169
        }

#line 169
        Ray_0 _S35;

#line 177
        if(hit_anything_0)
        {

#line 177
            float3 direction_2;

            switch((&(&info_1)->mat_0)->type_0)
            {
            case int(0):
                {

#line 181
                    float4 color_1 = color_0 * float4((&(&info_1)->mat_0)->albedo_0.xyz, 1.0);

                    float3 direction_3 = normalize((&info_1)->normal_0 + rand_vector_3_0(seed_4 + float(bounces_0) * 7.23000001907348633));
                    if((dot((&info_1)->normal_0, direction_3)) <= 0.0)
                    {

#line 184
                        direction_2 = - direction_3;

#line 184
                    }
                    else
                    {

#line 184
                        direction_2 = direction_3;

#line 184
                    }

#line 184
                    color_0 = color_1;


                    break;
                }
            case int(1):
                {

#line 189
                    float4 color_2 = color_0 * float4((&(&info_1)->mat_0)->albedo_0.xyz, 1.0);

                    float3 direction_4 = normalize(_S30.direction_0 - float3((2.0 * dot(_S30.direction_0, (&info_1)->normal_0)))  * (&info_1)->normal_0) + float3((&(&info_1)->mat_0)->fuzz_0)  * rand_vector_3_0(seed_4 + float(bounces_0) * 3.1099998950958252 + (&(&info_1)->mat_0)->fuzz_0 * 1.23000001907348633);
                    if((dot((&info_1)->normal_0, direction_4)) <= 0.0)
                    {

#line 192
                        direction_2 = - direction_4;

#line 192
                    }
                    else
                    {

#line 192
                        direction_2 = direction_4;

#line 192
                    }

#line 192
                    color_0 = color_2;


                    break;
                }
            case int(2):
                {

#line 195
                    float ri_0;


                    if((&info_1)->front_face_0)
                    {

#line 198
                        ri_0 = 1.0 / (&(&info_1)->mat_0)->refraction_index_0;

#line 198
                    }
                    else
                    {

#line 198
                        ri_0 = (&(&info_1)->mat_0)->refraction_index_0;

#line 198
                    }
                    float3 unit_vector_0 = normalize(_S30.direction_0);
                    float _S36 = min(dot(- unit_vector_0, (&info_1)->normal_0), 1.0);


                    float r0_0 = (1.0 - ri_0) / (1.0 + ri_0);
                    float r0_1 = r0_0 * r0_0;
                    float r0_2 = r0_1 + (1.0 - r0_1) * pow(1.0 - _S36, 5.0);

#line 205
                    bool _S37;

                    if((sqrt(1.0 - _S36 * _S36) * ri_0) > 1.0)
                    {

#line 207
                        _S37 = true;

#line 207
                    }
                    else
                    {

#line 207
                        _S37 = r0_2 > (rand_0(seed_4 + float(bounces_0) * 3.21000003814697266));

#line 207
                    }

#line 207
                    if(_S37)
                    {

#line 207
                        direction_2 = unit_vector_0 - float3((2.0 * dot(unit_vector_0, (&info_1)->normal_0)))  * (&info_1)->normal_0;

#line 207
                    }
                    else
                    {
                        float3 r_out_perp_0 = float3(ri_0)  * (unit_vector_0 + float3(_S36)  * (&info_1)->normal_0);
                        float _S38 = length(r_out_perp_0);

#line 211
                        direction_2 = r_out_perp_0 + float3(- sqrt(abs(1.0 - _S38 * _S38)))  * (&info_1)->normal_0;

#line 207
                    }

#line 214
                    break;
                }
            default:
                {

#line 214
                    break;
                }
            }

#line 214
            _S35 = Ray_x24init_0((&info_1)->p_0, direction_2);

#line 177
        }
        else
        {

#line 219
            float a_1 = 0.5 * (normalize(_S30.direction_0).y + 1.0);

#line 219
            color_0 = color_0 * (float4((1.0 - a_1))  + float4(a_1)  * float4(0.5, 0.69999998807907104, 1.0, 1.0));

            break;
        }

#line 164
        int _S39 = bounces_0 + int(1);

#line 164
        _S30 = _S35;

#line 164
        bounces_0 = _S39;

#line 164
    }

#line 225
    return color_0;
}


#line 123
float gamma_correct_0(float v_3)
{

#line 124
    if(v_3 >= 0.0)
    {

#line 125
        return sqrt(v_3);
    }
    return v_3;
}


#line 230
[[kernel]] void computeMain(uint3 thread_id_0 [[thread_position_in_grid]], UniformData_0 constant* u_data_1 [[buffer(0)]], Sphere_0 device* spheres_1 [[buffer(1)]], texture2d<float, access::read_write> out_image_1 [[texture(0)]])
{

#line 230
    thread KernelContext_0 kernelContext_1;

#line 230
    (&kernelContext_1)->u_data_0 = u_data_1;

#line 230
    (&kernelContext_1)->spheres_0 = spheres_1;

#line 230
    (&kernelContext_1)->out_image_0 = out_image_1;
    float3 _S40 = u_data_1->pixel00_0.xyz;
    float3 _S41 = u_data_1->pixel_u_0.xyz;
    float3 _S42 = u_data_1->pixel_v_0.xyz;
    float3 _S43 = u_data_1->defocus_disk_u_0.xyz;
    float3 _S44 = u_data_1->defocus_disk_v_0.xyz;

    float3 _S45 = u_data_1->camera_position_0.xyz;

    thread float4 color_3 = float4(0.0, 0.0, 0.0, 0.0);

#line 239
    int i_3 = int(0);
    for(;;)
    {

#line 240
        if(i_3 < ((&kernelContext_1)->u_data_0->samples_per_pixel_0))
        {
        }
        else
        {

#line 240
            break;
        }

#line 241
        float _S46 = float(thread_id_0.x);

#line 241
        float _S47 = float(i_3);

#line 241
        float _S48 = float(thread_id_0.y);

        float3 pixel_center_0 = _S40 + float3((_S46 + (rand_0(float((&kernelContext_1)->u_data_0->r_seed_0) + _S47 * 2.18799996376037598 + _S46 * 1.29999995231628418 + _S48 * 6.32999992370605469) - 0.5)))  * _S41 + float3((_S48 + (rand_0(float((&kernelContext_1)->u_data_0->r_seed_0) + _S47 * 3.7909998893737793 + _S46 * 5.90000009536743164 + _S48 * 3.17000007629394531) - 0.5)))  * _S42;

#line 243
        float3 ray_origin_0;


        if(((&kernelContext_1)->u_data_0->defocus_angle_0) > 0.0)
        {

#line 247
            float3 p_2 = rand_vector_2_0(float((&kernelContext_1)->u_data_0->r_seed_0) + 1.92200005054473877 * _S47 + _S46 * 4.59999990463256836 + _S48 * 1.23000001907348633);

#line 247
            ray_origin_0 = _S45 + float3(p_2.x)  * _S43 + float3(p_2.y)  * _S44;

#line 246
        }
        else
        {

#line 246
            ray_origin_0 = _S45;

#line 246
        }

#line 254
        float _S49 = float((&kernelContext_1)->u_data_0->r_seed_0) + _S46 * 1.21000003814697266 + _S48 * 0.44999998807907104 + _S47 * 7.76999998092651367;

#line 254
        thread Ray_0 _S50 = Ray_x24init_0(ray_origin_0, pixel_center_0 - ray_origin_0);

#line 254
        float4 _S51 = ray_color_0(&_S50, _S49, &kernelContext_1);

#line 254
        color_3 = color_3 + _S51;

#line 240
        i_3 = i_3 + int(1);

#line 240
    }

#line 257
    float4 _S52 = color_3 / float4(float((&kernelContext_1)->u_data_0->samples_per_pixel_0)) ;

#line 257
    color_3 = _S52;

    color_3.x = gamma_correct_0(_S52.x);
    color_3.y = gamma_correct_0(color_3.y);
    color_3.z = gamma_correct_0(color_3.z);

    color_3.x = clamp(color_3.x, 0.0, 1.0);
    color_3.y = clamp(color_3.y, 0.0, 1.0);
    color_3.z = clamp(color_3.z, 0.0, 1.0);

    (&kernelContext_1)->out_image_0.write(color_3,uint2(int2(thread_id_0.xy)));
    return;
}

