#ifndef ARP_GI_INCLUDE
#define ARP_GI_INCLUDE

struct GI
{
    float3 diffuse;
};


GI GetGI(float2 lightMapUV)
{
    GI gi;
    gi.diffuse = float3(lightMapUV, 0.0);

    return gi;
}


#endif
