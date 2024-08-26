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
    GI_VERTEXINPUT_DATA
    
};

struct VertexOutput
{
    float4 positionCS:SV_POSITION;
    float3 positionWS:VAR_POSITION;
    float2 uv:VAR_BASE_UV;
    float3 normalWS:VAR_NORMAL;
    float2 lightmapUV:TEXCOORD0;
    GI_VERTEXOUTPUT_DATA
};

VertexOutput LitPassVertex(VertexInput input)
{
    VertexOutput output;
    output.positionWS = TransformObjectToWorld(input.positionOS);
    output.positionCS = TransformObjectToHClip(input.positionOS);
    output.uv = input.uv * _MainTex_ST.xy + _MainTex_ST.zw;
    output.normalWS =  TransformObjectToWorldNormal(input.normal);
    TRANSFORM_GI_DATA(input, output);
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
    GI gi = GetGI(GI_FRAG_DATA(input), surface);
    float3 lightColor = GetLighting(surface, brdf, gi);

    float3 finalCol = lightColor * brdf.diffuse;
    
    return float4(finalCol, surface.alpha);
}

#endif
