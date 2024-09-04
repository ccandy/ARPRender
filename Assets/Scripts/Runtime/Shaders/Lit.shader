Shader "ARP/Lit"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", color) = (1,1,1,1)
        _CutOff("Alpha Cutoff", Range(0.0,1.0)) = 0.5
        
        _Roughness("Roughness", Range(0,1)) = 0.5
        _Metallic("Metallic", Range(0,1)) = 0.5
        
        [Toggle(ARP_CLIPING)]ARP_CLIPING ("CLIPing", Float) = 1
        [Toggle(ARP_STATIC)]ARP_STATIC ("STATIC", Float) = 0
        
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("SrC Blend", float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("Dst Blend", float) = 0
        [Enum(Off,0,On,1)] _ZWrite("Z Write", Float) = 1
        
    }
    SubShader
    {
        LOD 100
        
        HLSLINCLUDE
        #include "Assets/Scripts/Runtime/ShaderLib/Util/Common.hlsl"
        #include "Assets/Scripts/Runtime/ShaderLib/Light/LitInput.hlsl"
        ENDHLSL
        Pass
        {
            Tags 
            { 
                "RenderType"="Opaque" 
                "LightMode" = "CustomLit"
            }
            Blend [_SrcBlend][_DstBlend]
            ZWrite [_ZWrite]
            
            HLSLPROGRAM
            #include "Assets/Scripts/Runtime/ShaderLib/LitPass.hlsl"
            #pragma shader_feature ARP_GPUINSTANCE_ON
            #pragma shader_feature ARP_SHADERBATCH_ON
            #pragma shader_feature ARP_CLIPING
            #pragma shader_feature ARP_PREMULTIPLY_ALPHA
            #pragma shader_feature ARP_STATIC
            #pragma shader_feature ARP_SHADOW_MASK_DISTANCE
            #pragma multi_compile _ ARP_DIRECTIONAL_PCF3 ARP_DIRECTIONAL_PCF5 ARP_DIRECTIONAL_PCF7
            #pragma multi_compile _ LIGHTMAP_ON
            
            #pragma vertex LitPassVertex
            #pragma fragment LitPassFrag
            
            ENDHLSL
        }

        Pass
        {
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
            
            ColorMask 0
            HLSLPROGRAM
            
            #include "Assets/Scripts/Runtime/ShaderLib/Shadow/ShadowCaster.hlsl"
            #pragma shader_feature ARP_CLIPING
            #pragma vertex ShadowCasterPassVertex
            #pragma fragment ShadowCasterPassFragement
            
            ENDHLSL
        }

        /*Pass
        {
            Name "META"
            Tags 
            {
				"LightMode" = "Meta"
			}
            
            Cull Off
            
            HLSLPROGRAM
            #pragma target 3.5
            
            #include "Assets/Scripts/Runtime/ShaderLib/Light/MetaPass.hlsl"
            #pragma vertex MetaPassVertex
            #pragma fragment MetaPassFrag
            
            ENDHLSL
        }*/
    }
}
