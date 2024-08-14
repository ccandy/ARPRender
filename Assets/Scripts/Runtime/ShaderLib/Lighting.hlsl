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

float SpecularStrength(Surface surface, BRDF brdf, Light light)
{
    float roughness = brdf.roughness;
    float3 lightDir = light.lightDir;
    float3 viewDir = surface.viewDir;
    float3 normal = surface.normal;    

    
    float3 h = SafeNormalize(lightDir + viewDir);
    float nh2 = Square(saturate(dot(normal, h)));
    float lh2 = Square(saturate(dot(lightDir, h)));
    float r2 = Square(roughness);
    float d2 = Square(nh2 * (r2 - 1) + 1.0001);
    float normalization = roughness * 4.0 + 2.0;
    float result = r2 / (d2 * max(0.1, lh2) * normalization);
    
}


#endif
