#ifndef ARP_UNLIT_PASS_INCLUDE
#define ARP_UNLIT_PASS_INCLUDE

#include "Common.hlsl"

CBUFFER_START(UnityPerMaterial)
    float4 _Color;
CBUFFER_END

TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex); 

struct VertexInput
{
    float3 positionOS: POSITION;
    float2 uv: TEXCOORD0;
};

struct VertexOutput
{
    float4 positionCS:SV_POSITION;
    float2 uv:VAR_BASE_UV;
};


VertexOutput UnlitPassVertex(VertexInput input)
{
    VertexOutput output;
    
    output.positionCS = TransformObjectToHClip(input.positionOS);
    output.uv = input.uv;
    return output;
}

half4 UnlitPassFrag(VertexOutput input) : SV_TARGET
{
    float4 mainTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
    half4 col = mainTex * _Color;
    return col ;
}

#endif
