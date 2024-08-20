#ifndef ARP_SURFACE_INCLUDE
#define ARP_SURFACE_INCLUDE

struct Surface
{
    float3 normal;
    float3 color;
    float3 viewDir;
    float3 positionWS;
    float metallic;
    float roughness;
    float alpha;
    float depth;
};

Surface GetSurface(float4 col, float3 normal, float3 posWS, float roughness, float metallic)
{
    Surface surface;
    
    surface.color = col.rgb;
    surface.alpha = col.a;
    surface.normal = normal;
    surface.positionWS = posWS;
    surface.roughness = roughness;
    surface.metallic = metallic;
    surface.viewDir = normalize(_WorldSpaceCameraPos - posWS);
    surface.depth = -TransformWorldToView(posWS).z;
    
    return surface;
}


#endif
