#ifndef ARP_SHADOWCASTER_INCLUDE
#define ARP_SHADOWCASTER_INCLUDE

#include "Common.hlsl"

TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);

float _CutOff;
float4 _Color;
float4 _MainTex_ST;

struct VertexShadowInput
{
    float3 positionOS: POSITION;
    float2 uv: TEXCOORD0;
};

struct VertexShadowOutput
{
    float4 positionCS:SV_POSITION;
    float2 uv:VAR_BASE_UV;
};

VertexShadowOutput ShadowCasterPassVertex(VertexShadowInput input)
{
    VertexShadowOutput output;

    output.positionCS = TransformObjectToHClip(input.positionOS);
    output.uv = TRANSFORM_TEX(input.uv, _MainTex);

    return output;
}

void ShadowCasterPassFragement(VertexShadowOutput input)
{
    float4 baseColor = _Color;
    float4 mainTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
    half4 col = baseColor * mainTex;
    #if defined(ARP_CLIPING)
        clip(col.a - _CutOff)
    #endif
}


#endif
