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
    float4 _ShadowCascadeData[MAX_CASACDE_COUNT];
    int _CascadeCount;
    float4 _ShadowDistanceFade;
CBUFFER_END

struct ShadowData
{
    int cascadeIndex;
    float shadowStrength;
};


float FadeShadowStrength(float distance, float scale, float fade)
{
    return saturate((1 - distance * scale) * fade);
}

ShadowData GetShadowData(Surface surface)
{
    ShadowData data;
    data.shadowStrength = FadeShadowStrength(surface.depth, _ShadowDistanceFade.x, _ShadowDistanceFade.y);
    int i;
    for(i = 0; i <_CascadeCount; i++)
    {
        float4 sphere = _CascadeSphereCullingSphere[i];
        float sphereScale = _ShadowCascadeData[i].x;
        const float distanceSqr = DistanceSquared(surface.positionWS, sphere.xyz);
        if(distanceSqr < sphere.w)
        {
            if(i == _CascadeCount - 1)
            {
                data.shadowStrength *= FadeShadowStrength(distanceSqr, sphereScale, _ShadowDistanceFade.z);
            }
            
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
    directionalshadowdata.tileIndex = data.y *_CascadeCount+ shadowdata.cascadeIndex;
    return directionalshadowdata;
}

float SampleDirectionlShadowAltas(float3 shadowPos)
{
    return SAMPLE_TEXTURE2D_SHADOW(_DirectionalShadowAtlas,sampler_DirectionalShadowAtlas, shadowPos);
}

float GetDirectionalAtten(Surface surface, DirectionalShadowData data, ShadowData shadowdata)
{
    float shadowStrength = data.strength;
    if(shadowStrength <= 0)
    {
        return 1.0;
    }
    
    float3 posWS = surface.positionWS;
    int tileIndex = data.tileIndex;
   
    float4x4 worldToShadowMatrix = _DirectonalShadowMatrics[tileIndex];
    float3 normalBis = surface.normal * _ShadowCascadeData[shadowdata.cascadeIndex].y;
    float3 shadowPos = mul(worldToShadowMatrix,float4(posWS + normalBis,1));

    float shadowAtten = SampleDirectionlShadowAltas(shadowPos);
    shadowAtten = lerp(1.0, shadowAtten, shadowStrength);
    
    return shadowAtten;
}

#endif
