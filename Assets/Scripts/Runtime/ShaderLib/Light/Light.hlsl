#ifndef ARP_LIGHT_INCLUDE
#define ARP_LIGHT_INCLUDE

#define MAX_DIRECTIONALLIGHT_COUNT 4
#define MAX_ADDITIONALLIGHT_COUNT 4

CBUFFER_START(_CustomLight)
    float3 _directionalLightColors[MAX_DIRECTIONALLIGHT_COUNT];
    float3 _directionalLightDirs[MAX_DIRECTIONALLIGHT_COUNT];
    int _direcionalLightCount;

    int _additionalLightCount;
    float3 _additionalLightColors[MAX_ADDITIONALLIGHT_COUNT];
    float4 additionalLightPos[MAX_ADDITIONALLIGHT_COUNT];
    
CBUFFER_END


struct Light
{
    float3 color;
    float3 lightDir;
    float atten;
};

Light GetDirectionLight(int index)
{
    Light light;
    light.color     = _directionalLightColors[index];
    light.lightDir  = _directionalLightDirs[index];
    light.atten     = 1;
    
    return light;
}

int GetAdditionalLightCount()
{
    return _additionalLightCount;
}

float GetRangeAtten(float distanceSqr, float range)
{
    return Square(saturate(1.0 - Square(distanceSqr * range)))/distanceSqr;
}

Light GetAdditionalLight(int index, Surface surface)
{
    Light light;
    light.color = _additionalLightColors[index];
    float3 worldPos = surface.positionWS;
    float3 lightPos = additionalLightPos[index].xyz;
    
    float3 ray = lightPos - worldPos;
    light.lightDir = normalize(ray);
    float distanceSqr = max(0.00001, dot(ray, ray));
    float range = additionalLightPos[index].w;
    light.atten = GetRangeAtten(distanceSqr,range);
    
    return light;
}


#endif
