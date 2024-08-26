#ifndef ARP_UNITYINPUT_INCLUDE
#define ARP_UNITYINPUT_INCLUDE

CBUFFER_START(UnityPerDraw)
    float4x4 unity_ObjectToWorld;
    float4x4 unity_WorldToObject;
    float4 unity_LODFade;
    real4 unity_WorldTransformParams;
    //GI
    float4 unity_LightmapST;
    float4 unity_DynamicLightmapST;

CBUFFER_END

float4x4 unity_MatrixVP;
float4x4 unity_MatrixV;
float4x4 unity_MatrixInvV;
float4x4 unity_prev_MatrixM;
float4x4 unity_prev_MatrixIM;
float4x4 glstate_matrix_projection;

float3 _WorldSpaceCameraPos;

CBUFFER_START(UnityPerMaterial)
    float4 _Color;
    float _CutOff;
    float _Roughness;
    float _Metallic;
    float4 _MainTex_ST;
CBUFFER_END

#endif