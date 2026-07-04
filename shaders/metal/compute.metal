#include <metal_stdlib>
#include <metal_math>
#include <metal_texture>
using namespace metal;

#line 91 "./shaders.slang"
float rand_0(float seed_0)
{
    return fract(sin(seed_0 * 12.97999954223632812 + 78.23000335693359375) * 43879.5390625);
}

float rand_range_0(float seed_1, float r_min_0, float r_max_0)
{

#line 97
    return r_min_0 + rand_0(seed_1) * (r_max_0 - r_min_0);
}


#line 119
float3 rand_vector_2_0(float seed_2)
{
    float _S1 = seed_2 * 4.3899998664855957;
    float _S2 = seed_2 * 5.01000022888183594;

#line 122
    float3 v_0 = float3(rand_range_0(_S1, -1.0, 1.0), rand_range_0(_S2, -1.0, 1.0), 0.0);

#line 122
    int i_0 = int(0);


    for(;;)
    {

#line 125
        if(i_0 < int(10))
        {
        }
        else
        {

#line 125
            break;
        }

#line 126
        if((length(v_0)) <= 1.0)
        {

#line 127
            return v_0;
        }

        float _S3 = float(i_0) * 2.5559999942779541;

#line 129
        float3 _S4 = float3(rand_range_0(_S1 + _S3, -1.0, 1.0), rand_range_0(_S2 + _S3, -1.0, 1.0), 0.0);

#line 125
        int _S5 = i_0 + int(1);

#line 125
        v_0 = _S4;

#line 125
        i_0 = _S5;

#line 125
    }

#line 135
    return float3(0.0, 0.0, 0.0);
}


#line 86
struct Ray_0
{
    float3 origin_0;
    float3 direction_0;
};


#line 86
Ray_0 Ray_x24init_0(float3 origin_1, float3 direction_1)
{

#line 86
    thread Ray_0 _S6;
    (&_S6)->origin_0 = origin_1;
    (&_S6)->direction_0 = direction_1;

#line 86
    return _S6;
}


#line 50
struct Material_0
{
    int type_0;
    float4 albedo_0;
    float fuzz_0;
    float refraction_index_0;
};


#line 50
Material_0 Material_x24init_0(int type_1, float4 albedo_1, float fuzz_1, float refraction_index_1)
{

#line 50
    thread Material_0 _S7;
    (&_S7)->type_0 = type_1;
    (&_S7)->albedo_0 = albedo_1;
    (&_S7)->fuzz_0 = fuzz_1;
    (&_S7)->refraction_index_0 = refraction_index_1;

#line 50
    return _S7;
}


#line 78
struct HitInfo_0
{
    float t_0;
    float3 p_0;
    float3 normal_0;
    bool front_face_0;
    Material_0 mat_0;
};


#line 78
HitInfo_0 HitInfo_x24init_0(float t_1, float3 p_1, float3 normal_1, bool front_face_1, const Material_0 thread* mat_1)
{

#line 78
    thread HitInfo_0 _S8;
    (&_S8)->t_0 = t_1;
    (&_S8)->p_0 = p_1;
    (&_S8)->normal_0 = normal_1;
    (&_S8)->front_face_0 = front_face_1;
    (&_S8)->mat_0 = *mat_1;

#line 78
    return _S8;
}


#line 57
struct Sphere_0
{
    float4 center_0;
    float radius_0;
    Material_0 material_0;
};


#line 184
bool hit_sphere_0(const Sphere_0 thread* sphere_0, const Ray_0 thread* ray_0, HitInfo_0 thread* info_0, float t_min_0, float t_max_0)
{

#line 185
    float3 _S9 = sphere_0->center_0.xyz;

#line 185
    float3 _S10 = ray_0->origin_0;

#line 185
    float3 oc_0 = _S9 - ray_0->origin_0;

#line 185
    float3 _S11 = ray_0->direction_0;
    float a_0 = dot(ray_0->direction_0, ray_0->direction_0);
    float b_0 = -2.0 * dot(ray_0->direction_0, oc_0);

#line 187
    float _S12 = sphere_0->radius_0;

    float discriminant_0 = b_0 * b_0 - 4.0 * a_0 * (dot(oc_0, oc_0) - sphere_0->radius_0 * sphere_0->radius_0);

#line 80
    float3 _S13 = float3(0.0) ;

#line 80
    thread Material_0 _S14 = Material_x24init_0(int(0), float4(0.0) , 0.0, 0.0);

#line 80
    HitInfo_0 _S15 = HitInfo_x24init_0(0.0, _S13, _S13, false, &_S14);

#line 191
    *info_0 = _S15;

    if(discriminant_0 <= 0.0)
    {

#line 194
        return false;
    }

    float _S16 = - b_0;

#line 197
    float _S17 = sqrt(discriminant_0);

#line 197
    float _S18 = 2.0 * a_0;

#line 197
    float t_2 = (_S16 - _S17) / _S18;

#line 197
    bool _S19;
    if(t_2 <= t_min_0)
    {

#line 198
        _S19 = true;

#line 198
    }
    else
    {

#line 198
        _S19 = t_max_0 <= t_2;

#line 198
    }

#line 198
    float t_3;

#line 198
    if(_S19)
    {

#line 199
        float t_4 = (_S16 + _S17) / _S18;
        if(t_4 <= t_min_0)
        {

#line 200
            _S19 = true;

#line 200
        }
        else
        {

#line 200
            _S19 = t_max_0 <= t_4;

#line 200
        }

#line 200
        if(_S19)
        {

#line 201
            return false;
        }

#line 201
        t_3 = t_4;

#line 198
    }
    else
    {

#line 198
        t_3 = t_2;

#line 198
    }

#line 205
    info_0->mat_0 = sphere_0->material_0;
    info_0->t_0 = t_3;
    float3 _S20 = _S10 + float3(t_3)  * _S11;

#line 207
    info_0->p_0 = _S20;
    float3 outwards_normal_0 = (_S20 - _S9) / float3(_S12) ;
    bool _S21 = (dot(_S11, outwards_normal_0)) <= 0.0;

#line 209
    info_0->front_face_0 = _S21;

#line 209
    float3 _S22;
    if(_S21)
    {

#line 210
        _S22 = outwards_normal_0;

#line 210
    }
    else
    {

#line 210
        _S22 = - outwards_normal_0;

#line 210
    }

#line 210
    info_0->normal_0 = _S22;

    return true;
}


#line 64
struct BoundingBox_0
{
    float4 x_0;
    float4 y_0;
    float4 z_0;
};


#line 145
float4 get_box_axis_0(const BoundingBox_0 thread* b_1, int axis_0)
{

#line 146
    if(axis_0 == int(0))
    {

#line 146
        return b_1->x_0;
    }

#line 147
    if(axis_0 == int(1))
    {

#line 147
        return b_1->y_0;
    }

#line 148
    return b_1->z_0;
}

bool hit_bounding_box_0(const BoundingBox_0 thread* box_0, const Ray_0 thread* ray_1, float t_min_1, float t_max_1)
{

#line 152
    thread float2 hit_interval_0 = float2(t_min_1, t_max_1);

#line 152
    int i_1 = int(0);

    for(;;)
    {

#line 154
        if(i_1 < int(3))
        {
        }
        else
        {

#line 154
            break;
        }

#line 154
        float4 _S23 = get_box_axis_0(box_0, i_1);

#line 154
        float _S24 = ray_1->direction_0[i_1];


        if((abs(ray_1->direction_0[i_1])) < 9.99999997475242708e-07)
        {

#line 157
            float _S25 = ray_1->origin_0[i_1];

#line 157
            bool _S26;
            if((ray_1->origin_0[i_1]) < (_S23[int(0)]))
            {

#line 158
                _S26 = true;

#line 158
            }
            else
            {

#line 158
                _S26 = _S25 > (_S23[int(1)]);

#line 158
            }

#line 158
            if(_S26)
            {

#line 159
                return false;
            }
            i_1 = i_1 + int(1);

#line 154
            continue;
        }

#line 164
        float t0_0 = (_S23[int(0)] - ray_1->origin_0[i_1]) / _S24;
        float t1_0 = (_S23[int(1)] - ray_1->origin_0[i_1]) / _S24;

#line 165
        float t0_1;

#line 165
        float t1_1;

        if(t0_0 > t1_0)
        {

#line 167
            t0_1 = t1_0;

#line 167
            t1_1 = t0_0;

#line 167
        }
        else
        {

#line 167
            t0_1 = t0_0;

#line 167
            t1_1 = t1_0;

#line 167
        }

#line 173
        float _S27 = max(hit_interval_0.x, t0_1);

#line 173
        hit_interval_0.x = _S27;
        float _S28 = min(hit_interval_0.y, t1_1);

#line 174
        hit_interval_0.y = _S28;

        if(_S27 > _S28)
        {

#line 177
            return false;
        }

#line 154
        i_1 = i_1 + int(1);

#line 154
    }

#line 181
    return true;
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
    float4 v_1;
    float4 w_0;
    float4 defocus_disk_u_0;
    float4 defocus_disk_v_0;
    float4 pixel00_0;
    int sphere_count_0;
    int samples_per_pixel_0;
    float t_min_2;
    float t_max_2;
    int max_bounces_0;
    int bvh_node_count_0;
    int use_bvh_0;
};


#line 70
struct BVHNode_0
{
    BoundingBox_0 bbox_0;
    int left_0;
    int right_0;
    int count_0;
};


#line 4889 "hlsl.meta.slang"
struct KernelContext_0
{
    UniformData_0 constant* u_data_0;
    Sphere_0 device* spheres_0;
    BVHNode_0 device* bvh_list_0;
    texture2d<float, access::read_write> out_image_0;
};


#line 215 "./shaders.slang"
bool hit_bvh_0(const Ray_0 thread* ray_2, HitInfo_0 thread* info_1, float t_min_3, float t_max_3, KernelContext_0 thread* kernelContext_0)
{

#line 80
    float3 _S29 = float3(0.0) ;

#line 80
    thread Material_0 _S30 = Material_x24init_0(int(0), float4(0.0) , 0.0, 0.0);

#line 80
    HitInfo_0 _S31 = HitInfo_x24init_0(0.0, _S29, _S29, false, &_S30);

#line 216
    *info_1 = _S31;
    info_1->t_0 = t_max_3;

#line 222
    thread array<int, int(256)> stack_0;

    stack_0[int(0)] = kernelContext_0->u_data_0->bvh_node_count_0 - int(1);

#line 224
    bool hit_anything_0 = false;

#line 224
    int stack_ptr_0 = int(1);

#line 224
    int n_0 = int(0);


    for(;;)
    {

#line 227
        bool _S32;

#line 227
        if(stack_ptr_0 > int(0))
        {

#line 227
            _S32 = n_0 < int(2000);

#line 227
        }
        else
        {

#line 227
            _S32 = false;

#line 227
        }

#line 227
        if(_S32)
        {
        }
        else
        {

#line 227
            break;
        }

#line 228
        int stack_ptr_1 = stack_ptr_0 - int(1);
        BVHNode_0 bvh_node_0 = kernelContext_0->bvh_list_0[stack_0[stack_ptr_1]];

#line 229
        int stack_ptr_2;

        if((bvh_node_0.count_0) == int(1))
        {

#line 231
            thread Sphere_0 _S33 = kernelContext_0->spheres_0[bvh_node_0.left_0];
            thread HitInfo_0 tmp_0;

#line 232
            bool _S34 = hit_sphere_0(&_S33, ray_2, &tmp_0, t_min_3, info_1->t_0);

#line 232
            bool hit_anything_1;
            if(_S34)
            {
                *info_1 = tmp_0;

#line 235
                hit_anything_1 = true;

#line 233
            }
            else
            {

#line 233
                hit_anything_1 = hit_anything_0;

#line 233
            }

#line 233
            hit_anything_0 = hit_anything_1;

#line 233
            stack_ptr_2 = stack_ptr_1;

#line 231
        }
        else
        {

#line 231
            thread BoundingBox_0 _S35 = bvh_node_0.bbox_0;

#line 231
            bool _S36 = hit_bounding_box_0(&_S35, ray_2, t_min_3, info_1->t_0);

#line 238
            if(_S36)
            {

#line 239
                if((bvh_node_0.left_0) != int(-1))
                {

#line 240
                    int _S37 = stack_ptr_1 + int(1);

#line 240
                    stack_0[stack_ptr_1] = bvh_node_0.left_0;

#line 240
                    stack_ptr_2 = _S37;

#line 239
                }
                else
                {

#line 239
                    stack_ptr_2 = stack_ptr_1;

#line 239
                }

#line 239
                int stack_ptr_3;


                if((bvh_node_0.right_0) != int(-1))
                {

#line 243
                    int _S38 = stack_ptr_2 + int(1);

#line 243
                    stack_0[stack_ptr_2] = bvh_node_0.right_0;

#line 243
                    stack_ptr_3 = _S38;

#line 242
                }
                else
                {

#line 242
                    stack_ptr_3 = stack_ptr_2;

#line 242
                }

#line 242
                stack_ptr_2 = stack_ptr_3;

#line 238
            }
            else
            {

#line 238
                stack_ptr_2 = stack_ptr_1;

#line 238
            }

#line 231
        }

#line 248
        int _S39 = n_0 + int(1);

#line 248
        stack_ptr_0 = stack_ptr_2;

#line 248
        n_0 = _S39;

#line 227
    }

#line 251
    return hit_anything_0;
}


#line 100
float3 rand_vector_3_0(float seed_3)
{
    float _S40 = seed_3 * 3.49000000953674316;
    float _S41 = seed_3 * 5.01000022888183594;
    float _S42 = seed_3 * 1.87999999523162842;

#line 104
    float3 v_2 = float3(rand_range_0(_S40, -1.0, 1.0), rand_range_0(_S41, -1.0, 1.0), rand_range_0(_S42, -1.0, 1.0));

#line 104
    int i_2 = int(0);

    for(;;)
    {

#line 106
        if(i_2 < int(10))
        {
        }
        else
        {

#line 106
            break;
        }

#line 107
        if((length(v_2)) <= 1.0)
        {

#line 108
            return v_2;
        }

        float _S43 = float(i_2) * 2.5559999942779541;

#line 110
        float3 _S44 = float3(rand_range_0(_S40 + _S43, -1.0, 1.0), rand_range_0(_S41 + _S43, -1.0, 1.0), rand_range_0(_S42 + _S43, -1.0, 1.0));

#line 106
        int _S45 = i_2 + int(1);

#line 106
        v_2 = _S44;

#line 106
        i_2 = _S45;

#line 106
    }

#line 116
    return float3(0.0, 0.0, 0.0);
}


#line 254
float4 ray_color_0(const Ray_0 thread* ray_3, float seed_4, KernelContext_0 thread* kernelContext_1)
{

#line 255
    float4 _S46 = float4(1.0, 1.0, 1.0, 1.0);

#line 255
    Ray_0 _S47 = *ray_3;

#line 255
    int bounces_0 = int(0);

#line 255
    float4 color_0 = _S46;

    for(;;)
    {

#line 257
        if(bounces_0 < (kernelContext_1->u_data_0->max_bounces_0))
        {
        }
        else
        {

#line 257
            break;
        }

#line 258
        thread HitInfo_0 info_2;

#line 258
        bool hit_anything_2;


        if((kernelContext_1->u_data_0->use_bvh_0) == int(0))
        {

#line 262
            (&info_2)->t_0 = kernelContext_1->u_data_0->t_max_2;

#line 262
            hit_anything_2 = false;

#line 262
            int i_3 = int(0);

            for(;;)
            {

#line 264
                if(i_3 < (kernelContext_1->u_data_0->sphere_count_0))
                {
                }
                else
                {

#line 264
                    break;
                }
                float _S48 = kernelContext_1->u_data_0->t_min_2;

#line 266
                thread Sphere_0 _S49 = kernelContext_1->spheres_0[i_3];

#line 266
                thread Ray_0 _S50 = _S47;

#line 265
                thread HitInfo_0 tmp_1;

#line 265
                bool _S51 = hit_sphere_0(&_S49, &_S50, &tmp_1, _S48, (&info_2)->t_0);
                if(_S51)
                {

#line 267
                    info_2 = tmp_1;

#line 267
                    hit_anything_2 = true;

#line 266
                }

#line 264
                i_3 = i_3 + int(1);

#line 264
            }

#line 261
        }
        else
        {

#line 272
            if((kernelContext_1->u_data_0->bvh_node_count_0) > int(0))
            {

#line 273
                float _S52 = kernelContext_1->u_data_0->t_min_2;

#line 273
                float _S53 = kernelContext_1->u_data_0->t_max_2;

#line 273
                thread Ray_0 _S54 = _S47;

#line 273
                bool _S55 = hit_bvh_0(&_S54, &info_2, _S52, _S53, kernelContext_1);

#line 273
                hit_anything_2 = _S55;

#line 272
            }
            else
            {

#line 272
                hit_anything_2 = false;

#line 272
            }

#line 261
        }

#line 261
        Ray_0 _S56;

#line 277
        if(hit_anything_2)
        {

#line 277
            float3 direction_2;

            switch((&(&info_2)->mat_0)->type_0)
            {
            case int(0):
                {

#line 281
                    float4 color_1 = color_0 * float4((&(&info_2)->mat_0)->albedo_0.xyz, 1.0);

                    float3 direction_3 = normalize((&info_2)->normal_0 + rand_vector_3_0(seed_4 + float(bounces_0) * 7.23000001907348633));
                    if((dot((&info_2)->normal_0, direction_3)) <= 0.0)
                    {

#line 284
                        direction_2 = - direction_3;

#line 284
                    }
                    else
                    {

#line 284
                        direction_2 = direction_3;

#line 284
                    }

#line 284
                    color_0 = color_1;


                    break;
                }
            case int(1):
                {

#line 289
                    float4 color_2 = color_0 * float4((&(&info_2)->mat_0)->albedo_0.xyz, 1.0);

                    float3 direction_4 = normalize(_S47.direction_0 - float3((2.0 * dot(_S47.direction_0, (&info_2)->normal_0)))  * (&info_2)->normal_0) + float3((&(&info_2)->mat_0)->fuzz_0)  * rand_vector_3_0(seed_4 + float(bounces_0) * 3.1099998950958252 + (&(&info_2)->mat_0)->fuzz_0 * 1.23000001907348633);
                    if((dot((&info_2)->normal_0, direction_4)) <= 0.0)
                    {

#line 292
                        direction_2 = - direction_4;

#line 292
                    }
                    else
                    {

#line 292
                        direction_2 = direction_4;

#line 292
                    }

#line 292
                    color_0 = color_2;


                    break;
                }
            case int(2):
                {

#line 295
                    float ri_0;


                    if((&info_2)->front_face_0)
                    {

#line 298
                        ri_0 = 1.0 / (&(&info_2)->mat_0)->refraction_index_0;

#line 298
                    }
                    else
                    {

#line 298
                        ri_0 = (&(&info_2)->mat_0)->refraction_index_0;

#line 298
                    }
                    float3 unit_vector_0 = normalize(_S47.direction_0);
                    float _S57 = min(dot(- unit_vector_0, (&info_2)->normal_0), 1.0);


                    float r0_0 = (1.0 - ri_0) / (1.0 + ri_0);
                    float r0_1 = r0_0 * r0_0;
                    float r0_2 = r0_1 + (1.0 - r0_1) * pow(1.0 - _S57, 5.0);

#line 305
                    bool _S58;

                    if((sqrt(1.0 - _S57 * _S57) * ri_0) > 1.0)
                    {

#line 307
                        _S58 = true;

#line 307
                    }
                    else
                    {

#line 307
                        _S58 = r0_2 > (rand_0(seed_4 + float(bounces_0) * 3.21000003814697266));

#line 307
                    }

#line 307
                    if(_S58)
                    {

#line 307
                        direction_2 = unit_vector_0 - float3((2.0 * dot(unit_vector_0, (&info_2)->normal_0)))  * (&info_2)->normal_0;

#line 307
                    }
                    else
                    {
                        float3 r_out_perp_0 = float3(ri_0)  * (unit_vector_0 + float3(_S57)  * (&info_2)->normal_0);
                        float _S59 = length(r_out_perp_0);

#line 311
                        direction_2 = r_out_perp_0 + float3(- sqrt(abs(1.0 - _S59 * _S59)))  * (&info_2)->normal_0;

#line 307
                    }

#line 314
                    break;
                }
            default:
                {

#line 314
                    break;
                }
            }

#line 314
            _S56 = Ray_x24init_0((&info_2)->p_0, direction_2);

#line 277
        }
        else
        {

#line 319
            float a_1 = 0.5 * (normalize(_S47.direction_0).y + 1.0);

#line 319
            color_0 = color_0 * (float4((1.0 - a_1))  + float4(a_1)  * float4(0.5, 0.69999998807907104, 1.0, 1.0));

            break;
        }

#line 257
        int _S60 = bounces_0 + int(1);

#line 257
        _S47 = _S56;

#line 257
        bounces_0 = _S60;

#line 257
    }

#line 325
    return color_0;
}


#line 138
float gamma_correct_0(float v_3)
{

#line 139
    if(v_3 >= 0.0)
    {

#line 140
        return sqrt(v_3);
    }
    return v_3;
}


#line 330
[[kernel]] void computeMain(uint3 thread_id_0 [[thread_position_in_grid]], UniformData_0 constant* u_data_1 [[buffer(0)]], Sphere_0 device* spheres_1 [[buffer(1)]], BVHNode_0 device* bvh_list_1 [[buffer(2)]], texture2d<float, access::read_write> out_image_1 [[texture(0)]])
{

#line 330
    thread KernelContext_0 kernelContext_2;

#line 330
    (&kernelContext_2)->u_data_0 = u_data_1;

#line 330
    (&kernelContext_2)->spheres_0 = spheres_1;

#line 330
    (&kernelContext_2)->bvh_list_0 = bvh_list_1;

#line 330
    (&kernelContext_2)->out_image_0 = out_image_1;
    float3 _S61 = u_data_1->pixel00_0.xyz;
    float3 _S62 = u_data_1->pixel_u_0.xyz;
    float3 _S63 = u_data_1->pixel_v_0.xyz;
    float3 _S64 = u_data_1->defocus_disk_u_0.xyz;
    float3 _S65 = u_data_1->defocus_disk_v_0.xyz;

    float3 _S66 = u_data_1->camera_position_0.xyz;

    thread float4 color_3 = float4(0.0, 0.0, 0.0, 0.0);

#line 339
    int i_4 = int(0);
    for(;;)
    {

#line 340
        if(i_4 < ((&kernelContext_2)->u_data_0->samples_per_pixel_0))
        {
        }
        else
        {

#line 340
            break;
        }

#line 341
        float _S67 = float(thread_id_0.x);

#line 341
        float _S68 = float(i_4);

#line 341
        float _S69 = float(thread_id_0.y);

        float3 pixel_center_0 = _S61 + float3((_S67 + (rand_0(float((&kernelContext_2)->u_data_0->r_seed_0) + _S68 * 2.18799996376037598 + _S67 * 1.29999995231628418 + _S69 * 6.32999992370605469) - 0.5)))  * _S62 + float3((_S69 + (rand_0(float((&kernelContext_2)->u_data_0->r_seed_0) + _S68 * 3.7909998893737793 + _S67 * 5.90000009536743164 + _S69 * 3.17000007629394531) - 0.5)))  * _S63;

#line 343
        float3 ray_origin_0;


        if(((&kernelContext_2)->u_data_0->defocus_angle_0) > 0.0)
        {

#line 347
            float3 p_2 = rand_vector_2_0(float((&kernelContext_2)->u_data_0->r_seed_0) + 1.92200005054473877 * _S68 + _S67 * 4.59999990463256836 + _S69 * 1.23000001907348633);

#line 347
            ray_origin_0 = _S66 + float3(p_2.x)  * _S64 + float3(p_2.y)  * _S65;

#line 346
        }
        else
        {

#line 346
            ray_origin_0 = _S66;

#line 346
        }

#line 354
        float _S70 = float((&kernelContext_2)->u_data_0->r_seed_0) + _S67 * 1.21000003814697266 + _S69 * 0.44999998807907104 + _S68 * 7.76999998092651367;

#line 354
        thread Ray_0 _S71 = Ray_x24init_0(ray_origin_0, pixel_center_0 - ray_origin_0);

#line 354
        float4 _S72 = ray_color_0(&_S71, _S70, &kernelContext_2);

#line 354
        color_3 = color_3 + _S72;

#line 340
        i_4 = i_4 + int(1);

#line 340
    }

#line 357
    float4 _S73 = color_3 / float4(float((&kernelContext_2)->u_data_0->samples_per_pixel_0)) ;

#line 357
    color_3 = _S73;

    color_3.x = gamma_correct_0(_S73.x);
    color_3.y = gamma_correct_0(color_3.y);
    color_3.z = gamma_correct_0(color_3.z);

    color_3.x = clamp(color_3.x, 0.0, 1.0);
    color_3.y = clamp(color_3.y, 0.0, 1.0);
    color_3.z = clamp(color_3.z, 0.0, 1.0);

    (&kernelContext_2)->out_image_0.write(color_3,uint2(int2(thread_id_0.xy)));
    return;
}

