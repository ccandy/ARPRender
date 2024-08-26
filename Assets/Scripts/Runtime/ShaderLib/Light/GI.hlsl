#ifndef ARP_GI_INCLUDE
#define ARP_GI_INCLUDE

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/EntityLighting.hlsl"

TEXTURE2D(unity_Lightmap);
SAMPLER(samplerunity_Lightmap);

#if defined(LIGHTMAP_ON)

    #define GI_VERTEXINPUT_DATA float2 lightMapUV:TEXCOORD1;
    #define GI_VERTEXOUTPUT_DATA float lightMapUV: VAR_LIGHT_MAP_UV;
    #define TRANSFORM_GI_DATA(input,output) \
        output.lightMapUV = input.lightMapUV * \
        unity_LightmapST.xy + unity_LightmapST.zw
    #define GI_FRAG_DATA(input) input.lightMapUV

#else
    #define GI_VERTEXINPUT_DATA 
    #define GI_VERTEXOUTPUT_DATA 
    #define TRANSFORM_GI_DATA(input,output)
    #define GI_FRAG_DATA(input) 0.0
#endif

float3 SampleSingleLightmap(float2 lightmapUV)
{
    return SampleSingleLightmap(unity_Lightmap, samplerunity_Lightmap, lightmapUV, float4(1,1,0,0),
        #if defined(UNITY_LIGHTMAP_FULL_HDR)
            false,
        #else
            true,
        #endif
        float4(LIGHTMAP_HDR_MULTIPLIER, LIGHTMAP_HDR_EXPONENT, 0.0,0.0)
    );
}

float3 SampleLightmap(float2 lightmapUV)
{
    #if defined(LIGHTMAP_ON)
        return SampleSingleLightmap(lightmapUV);
    #else
        return 0.0;
    #endif
}


struct GI
{
    float3 diffuse;
};


GI GetGI(float2 lightMapUV)
{
    GI gi;
    gi.diffuse = SampleLightmap(lightMapUV);

    return gi;
}


#endif
