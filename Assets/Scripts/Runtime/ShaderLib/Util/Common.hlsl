#ifndef ARP_COMMON_INCLUDE
#define ARP_COMMON_INCLUDE


#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
#include "UnityInput.hlsl"

#define UNITY_MATRIX_M unity_ObjectToWorld
#define UNITY_MATRIX_I_M unity_WorldToObject
#define UNITY_MATRIX_V unity_MatrixV
#define UNITY_MATRIX_I_V unity_MatrixInvV
#define UNITY_MATRIX_VP unity_MatrixVP
#define UNITY_PREV_MATRIX_M unity_prev_MatrixM
#define UNITY_PREV_MATRIX_I_M unity_prev_MatrixIM
#define UNITY_MATRIX_P glstate_matrix_projection

#define TRANSFORM_TEX(tex, name)(tex.xy * name##_ST.xy + name##_ST.zw)

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"


#include "Math.hlsl"
#include "Surface.hlsl"
#include "Assets/Scripts/Runtime/ShaderLib/PBR/BRDF.hlsl"
#include "Assets/Scripts/Runtime/ShaderLib/Shadow//Shadow.hlsl"
#include "Assets/Scripts/Runtime/ShaderLib/Light/Light.hlsl"
#include "Assets/Scripts/Runtime/ShaderLib/Light/Lighting.hlsl"


#endif