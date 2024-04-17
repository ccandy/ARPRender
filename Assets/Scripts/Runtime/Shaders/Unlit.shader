Shader "ARP/Unlit"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", color) = (1,1,1,1)
        
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #include "Assets/Scripts/Runtime/ShaderLib/UnlitPass.hlsl"
            #pragma multi_compile_instancing
            #pragma multi_compile ARP_GPUINSTANCE_ON
            #pragma multi_compile ARP_SHADERBATCH_ON
            #pragma vertex UnlitPassVertex
            #pragma fragment UnlitPassFrag
            
            
            ENDHLSL
        }
    }
}
