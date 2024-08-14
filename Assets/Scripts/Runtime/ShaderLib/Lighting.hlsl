#ifndef ARP_LIGHTING_INCLUDE
#define ARP_LIGHTING_INCLUDE

float3 GetIncomingLight(Surface surface, Light light)
{
    return saturate(dot(surface.normal, light.lightDir)) * light.color;
}

float3 GetLighting(Surface surface, Light light)
{
    return GetIncomingLight(surface, light) * surface.color;
}


#endif
