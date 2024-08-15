#ifndef ARP_BRDF_INCLUDE
#define ARP_BRDF_INCLUDE

#define MIN_REFLECTIVITY 0.04

struct BRDF
{
    float3 diffuse;
    float3 specular;
    float roughness;
    float perceptualroughness;
    float metallc;
};

float OneMinsReflectivity(float metallc)
{
    float range = 1.0 - MIN_REFLECTIVITY;

    return range - metallc * range;
}

BRDF GetBRDF(Surface surface)
{
    BRDF brdf;
    float oneMinsReflectivity = OneMinsReflectivity(surface.metallic);
    brdf.diffuse = surface.color * oneMinsReflectivity;
    brdf.specular = lerp(MIN_REFLECTIVITY, surface.color, surface.metallic);
    brdf.roughness = surface.roughness;
    brdf.perceptualroughness = FastSqrt(surface.roughness);
    brdf.metallc = surface.metallic;

    return brdf;
}

#endif
