#ifndef ARP_GI_INCLUDE
#define ARP_GI_INCLUDE

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/EntityLighting.hlsl"

TEXTURE2D(unity_Lightmap);
SAMPLER(samplerunity_Lightmap);

#if defined(LIGHTMAP_ON)
    #define GI_VERTEXINPUT_DATA float2 lightMapUV:TEXCOORD1;
    #define GI_VERTEXOUTPUT_DATA float2 lightMapUV: VAR_LIGHT_MAP_UV;
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

float3 SampleLightProbe(Surface surface)
{
    #if defined(LIGHTMAP_ON)
        return 0.0;
    #else
        float4 coff[7];
        coff[0] = unity_SHAr;
        coff[1] = unity_SHAg;
        coff[2] = unity_SHAb;
        coff[3] = unity_SHBr;
        coff[4] = unity_SHBg;
        coff[5] = unity_SHBb;
        coff[6] = unity_SHC;
       return max(0.0, SampleSH9(coff, surface.normal));
    #endif
}


struct GI
{
    float3 diffuse;
};


GI GetGI(float2 lightMapUV, Surface surface)
{
    GI gi;
    gi.diffuse = SampleLightmap(lightMapUV) + SampleLightProbe(surface);
    return gi;
}


#endif
