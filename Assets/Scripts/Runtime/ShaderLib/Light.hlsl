#ifndef ARP_LIGHT_INCLUDE
#define ARP_LIGHT_INCLUDE

#define MAX_DIRECTIONAL_COUNT 4

CBUFFER_START(_CustomLight)
    float3 _directionalLightColors[MAX_DIRECTIONAL_COUNT];
    float3 _directionalLightDirs[MAX_DIRECTIONAL_COUNT];
    float _direcionalLightCount;
CBUFFER_END


struct Light
{
    float3 color;
    float3 lightDir;
};

Light GetDirectionLight(int index)
{
    Light light;
    light.color = _directionalLightColors[index];
    light.lightDir = _directionalLightDirs[index];

    return light;
}


#endif
