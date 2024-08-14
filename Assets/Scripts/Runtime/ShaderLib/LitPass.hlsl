#ifndef ARP_LIT_PASS_INCLUDE
#define ARP_LIT_PASS_INCLUDE

#include "Common.hlsl"
#include "Surface.hlsl"
#include "Light.hlsl"
#include "Lighting.hlsl"

TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex); 

struct VertexInput
{
    float3 positionOS: POSITION;
    float2 uv: TEXCOORD0;
    float3 normal:NORMAL;
    #if defined(ARP_GPUINSTANCE_ON)
        UNITY_VERTEX_INPUT_INSTANCE_ID
    #endif
};

struct VertexOutput
{
    float4 positionCS:SV_POSITION;
    float2 uv:VAR_BASE_UV;
    float3 normalWS:VAR_NORMAL;
    #if defined(ARP_GPUINSTANCE_ON)
        UNITY_VERTEX_INPUT_INSTANCE_ID
    #endif 
};

#if defined(ARP_GPUINSTANCE_ON)
    UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
        UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
        UNITY_DEFINE_INSTANCED_PROP(float4, _MainTex_ST)
        UNITY_DEFINE_INSTANCED_PROP(float, _CutOff)
    UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)
#else
    CBUFFER_START(UnityPerMaterial)
        float4 _Color;
        float _CutOff;
    CBUFFER_END
    float4 _MainTex_ST;
#endif

VertexOutput LitPassVertex(VertexInput input)
{
    VertexOutput output;
    #if defined(ARP_GPUINSTANCE_ON)
        UNITY_SETUP_INSTANCE_ID(input);
        float4 mainTexST = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _MainTex_ST);
    #else
        float4 mainTexST = _MainTex_ST;
    #endif
    output.positionCS = TransformObjectToHClip(input.positionOS);
    output.uv = input.uv * mainTexST.xy + mainTexST.zw;
    output.normalWS =  TransformObjectToWorldNormal(input.normal);
    
    return output;
}

half4 LitPassFrag(VertexOutput input) : SV_TARGET
{
    
    #if defined(ARP_GPUINSTANCE_ON)
        UNITY_SETUP_INSTANCE_ID(input);
        const half4 baseColor = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Color);
        const half cutOff = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _CutOff);
    #else
        half4 baseColor = _Color;
        half cutOff = _CutOff;
    #endif
    const half4 mainTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
    half4 col = mainTex * baseColor;
    #if defined(ARP_CLIPING)
        clip(col.a - cutOff);
    #endif

    Surface surface;
    surface.normal = normalize(input.normalWS);
    surface.color = col.rgb;
    surface.alpha = col.a;
    
    return float4(surface.color, surface.alpha);
}

#endif
