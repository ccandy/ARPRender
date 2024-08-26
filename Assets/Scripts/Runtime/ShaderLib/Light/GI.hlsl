#ifndef ARP_GI_INCLUDE
#define ARP_GI_INCLUDE

TEXTURE2D(unity_Lightmap);
SAMPLER(samplerunity_Lightmap);

#if defined(LIGHTMAP_ON)

    #define GI_VERTEXINPUT_DATA float2 lightMapUV:TEXCOORD1;
    #define GI_VERTEXOUTPUT_DATA float lightMapUV: VAR_LIGHT_MAP_UV;
    #defineTRANSFORM_GI_DATA(input,output)
        output.lightMapUV = input.lightMapUV
    #define GI_FRAG_DATA(input) input.lightMapUV

#else
    #define GI_VERTEXINPUT_DATA 
    #define GI_VERTEXOUTPUT_DATA 
    #define TRANSFORM_GI_DATA(input,output)
    #define GI_FRAG_DATA(input) 0.0
#endif

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
