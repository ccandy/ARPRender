#ifndef ARP_LIGHT_INCLUDE
#define ARP_LIGHT_INCLUDE

#define MAX_SHADOWED_DIRECTIONAL_COUNT 4

CBUFFER_START(_CustomLight)
    float3 _directionalLightColors[MAX_SHADOWED_DIRECTIONAL_COUNT];
    float3 _directionalLightDirs[MAX_SHADOWED_DIRECTIONAL_COUNT];
    float _direcionalLightCount;
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


#endif
