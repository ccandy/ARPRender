#ifndef ARP_SHADOW_INCLUDE
#define ARP_SHADOW_INCLUDE

#define MAX_SHADOWED_DIRECTIONAL_COUNT 4
#define MAX_CASACDE_COUNT 4
//To sample shadowmap, we need TEXTURE2D_SHADOW and SAMPLER_CMP
TEXTURE2D_SHADOW(_DirectionalShadowAtlas);
SAMPLER_CMP(sampler_DirectionalShadowAtlas);

CBUFFER_START(_CustomShadows)
    float4x4 _DirectonalShadowMatrics[16];
    float4 _DirectonalShadowData[MAX_SHADOWED_DIRECTIONAL_COUNT];
    float4 _CascadeSphereCullingSphere[MAX_CASACDE_COUNT];
    int _CascadeCount;
    float4 _ShadowDistanceFade;
CBUFFER_END

struct ShadowData
{
    int cascadeIndex;
    float shadowStrength;
};

ShadowData GetShadowData(Surface surface)
{
    ShadowData data;
    float shadowDistance = _ShadowDistanceFade.x;
    data.shadowStrength = surface.depth < shadowDistance.x ? 1.0 : 0.0;
    int i;
    for(i = 0; i <_CascadeCount; i++)
    {
        float4 sphere = _CascadeSphereCullingSphere[i];
        float distanceSqr = DistanceSquared(surface.positionWS, sphere.xyz);
        if(distanceSqr < sphere.w)
        {
            break;
        }
    }

    if(i == _CascadeCount)
    {
        data.shadowStrength == 0;
    }
    data.cascadeIndex = i;

    return data;
}

struct DirectionalShadowData
{
    float strength;
    int tileIndex;
};

DirectionalShadowData GetDirectionalShadowData(int lightIndex,ShadowData shadowdata)
{
    DirectionalShadowData directionalshadowdata;
    
    float4 data = _DirectonalShadowData[lightIndex];
    directionalshadowdata.strength = shadowdata.shadowStrength;
    directionalshadowdata.tileIndex = data.y + shadowdata.cascadeIndex;
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
