#ifndef ARP_SHADOW_INCLUDE
#define ARP_SHADOW_INCLUDE

#define MAX_SHADOWED_DIRECTIONAL_COUNT 4
#define MAX_CASACDE_COUNT 4
//To sample shadowmap, we need TEXTURE2D_SHADOW and SAMPLER_CMP
TEXTURE2D_SHADOW(_DirectionalShadowAtlas);
SAMPLER_CMP(sampler_DirectionalShadowAtlas);

CBUFFER_START(_CustomShadows)
    float4x4 _DirectonalShadowMatrics[MAX_SHADOWED_DIRECTIONAL_COUNT * MAX_CASACDE_COUNT];
    float4 _DirectonalShadowData[MAX_SHADOWED_DIRECTIONAL_COUNT];
CBUFFER_END

struct DirectionalShadowData
{
    float strength;
    int tileIndex;
};

DirectionalShadowData GetDirectionalShadowData(int lightIndex)
{
    DirectionalShadowData directionalshadowdata;
    
    float4 data = _DirectonalShadowData[lightIndex];
    directionalshadowdata.strength = data.x;
    directionalshadowdata.tileIndex = data.y;

    return directionalshadowdata;
}

float SampleDirectionlShadowAltas(float3 shadowPos)
{
    return SAMPLE_TEXTURE2D_SHADOW(_DirectionalShadowAtlas,sampler_DirectionalShadowAtlas, shadowPos);
}

float GetDirectionalAtten(Surface surface, DirectionalShadowData data)
{
    float shadowStrength = data.strength;
    float3 posWS = surface.positionWS;
    int tileIndex = data.tileIndex;
    float4x4 worldToShadowMatrix = _DirectonalShadowMatrics[tileIndex];
    float3 shadowPos = mul(worldToShadowMatrix,float4(posWS,1));

    float shadowAtten = SampleDirectionlShadowAltas(shadowPos);
    shadowAtten = lerp(1.0, shadowAtten, shadowStrength);
    
    return shadowAtten;
}

#endif
