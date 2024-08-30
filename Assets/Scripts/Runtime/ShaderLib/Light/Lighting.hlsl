#ifndef ARP_LIGHTING_INCLUDE
#define ARP_LIGHTING_INCLUDE

float3 GetIncomingLight(Surface surface, Light light)
{
    return saturate(dot(surface.normal, light.lightDir)) * light.color * light.atten * light.shadowAtten;
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

    return result;
    
}

float3 DirectBRDF(Surface surface, BRDF brdf, Light light)
{
    return SpecularStrength(surface, brdf, light) * brdf.specular + brdf.diffuse;
}

float3 GetLighting(Surface surface, BRDF brdf,GI gi)
{
    float3 lightCol = brdf.diffuse * gi.diffuse;
    for(int n = 0; n < _direcionalLightCount; n++)
    {
        Light light = GetDirectionLight(n,surface);
        lightCol += GetIncomingLight(surface, light) * DirectBRDF(surface, brdf, light);
    }

    int additonalLightCount = GetAdditionalLightCount();
    
    for(int n = 0; n < additonalLightCount; n++)
    {
        Light light = GetAdditionalLight(n, surface);
        lightCol += GetIncomingLight(surface, light);
    }

    return lightCol;
}

#endif
