#ifndef ARP_LIGHT_INCLUDE
#define ARP_LIGHT_INCLUDE

CBUFFER_START(_CustomLight)
    float3 _directionalLightColor;
    float3 _directionalLightDir;
CBUFFER_END


struct Light
{
    float3 color;
    float3 lightDir;
};

Light GetDirectionLight()
{
    Light light;
    light.color = _directionalLightColor;
    light.lightDir = _directionalLightDir;

    return light;
}


#endif
