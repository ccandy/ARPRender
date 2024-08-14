#ifndef ARP_LIGHTING_INCLUDE
#define ARP_LIGHTING_INCLUDE

float3 GetIncomingLight(Surface surface, Light light)
{
    return saturate(dot(surface.normal, light.lightDir)) * light.color;
}


float3 GetLighting(Surface surface)
{
    float3 lightCol = 0;
    
    for(int n = 0; n < _direcionalLightCount; n++)
    {
        Light light = GetDirectionLight(n);
        lightCol += GetIncomingLight(surface, light);
    }

    return lightCol;
}

#endif
