#ifndef ARP_SURFACE_INCLUDE
#define ARP_SURFACE_INCLUDE

struct Surface
{
    float3 normal;
    float3 color;
    float3 viewDir;
    float metallic;
    float roughness;
    float alpha;
};

Surface GetSurface(float4 col, float3 normal, float roughness, float metallic)
{
    Surface surface;

    surface.color = col.rgb;
    surface.alpha = col.a;
    surface.normal = normal;
    surface.roughness = roughness;
    surface.metallic = metallic;

    return surface;
}


#endif
