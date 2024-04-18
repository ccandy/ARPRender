Shader "ARP/Unlit"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", color) = (1,1,1,1)
        _CutOff("Alpha Cutoff", Range(0.0,1.0)) = 0.5
        
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("SrC Blend", float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("Dst Blend", float) = 0
        [Enum(Off,0,On,1)] _ZWrite("Z Write", Float) = 1
        
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Blend [_SrcBlend][_DstBlend]
            ZWrite [_ZWrite]
            
            HLSLPROGRAM
            #include "Assets/Scripts/Runtime/ShaderLib/UnlitPass.hlsl"
            #pragma multi_compile_instancing
            #pragma shader_feature ARP_GPUINSTANCE_ON
            #pragma shader_feature ARP_SHADERBATCH_ON
            #pragma shader_feature ARP_CLIPING
            #pragma vertex UnlitPassVertex
            #pragma fragment UnlitPassFrag
            
            
            ENDHLSL
        }
    }
}
