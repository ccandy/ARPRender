#ifndef ARP_LIT_PASS_INCLUDE
#define ARP_LIT_PASS_INCLUDE

#include "Assets/Scripts/Runtime/ShaderLib/Util/Common.hlsl"

TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex); 

struct VertexInput
{
    float3 positionOS: POSITION;
    float2 uv: TEXCOORD0;
    float3 normal:NORMAL;
    float2 uv2:TEXCOORD1;
#if defined(LIGHTMAP_ON)
    
#endif
    
};

struct VertexOutput
{
    float4 positionCS:SV_POSITION;
    float3 positionWS:VAR_POSITION;
    float2 uv:VAR_BASE_UV;
    float3 normalWS:VAR_NORMAL;
    float2 lightmapUV:TEXCOORD0;
#if defined(LIGHTMAP_ON)
    
#endif
};

VertexOutput LitPassVertex(VertexInput input)
{
    VertexOutput output;
    output.positionWS = TransformObjectToWorld(input.positionOS);
    output.positionCS = TransformObjectToHClip(input.positionOS);
    output.uv = input.uv * _MainTex_ST.xy + _MainTex_ST.zw;
    output.normalWS =  TransformObjectToWorldNormal(input.normal);
    
    //output.lightmapUV = unity_LightmapST.xy + unity_LightmapST.zw;

    
    return output;
}

half4 LitPassFrag(VertexOutput input) : SV_TARGET
{
    const half4 baseColor = _Color;
    const half cutOff = _CutOff;
    const half4 mainTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
    half4 col = mainTex * baseColor;
    #if defined(ARP_CLIPING)
        clip(col.a - cutOff);
    #endif

    Surface surface = GetSurface(col, input.normalWS, input.positionWS, _Roughness, _Metallic);
    
    BRDF brdf = GetBRDF(surface);
    GI gi = GetGI(0);
    float3 lightColor = GetLighting(surface, brdf, gi);

    float3 finalCol = lightColor * brdf.diffuse;
    
    return float4(finalCol, surface.alpha);
}

#endif
