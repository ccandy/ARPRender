using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

partial class CameraRender
{

    partial void DrawUnsupportedShaders();
    
    #if UNITY_EDITOR
        private static ShaderTagId unlitShaderTagId = new ShaderTagId("SRPDefaultUnlit");
    
        private static ShaderTagId[] legacyShaderTagIds =
        {
            new ShaderTagId("Always"),
            new ShaderTagId("ForwardBase"),
            new ShaderTagId("PrepassBase"),
            new ShaderTagId("Vertex"),
            new ShaderTagId("VertexLMRGBM"),
            new ShaderTagId("VertexLM")
        };

        private static Material _errorMat;
    
    
        partial void DrawUnsupportedShaders()
        {
            if (_errorMat == null)
            {
                _errorMat = new Material(Shader.Find("Hidden/Core/FallbackError"));
            }
            
            var drawSettings = new DrawingSettings
            (
                legacyShaderTagIds[0], new SortingSettings(_camera)
            )
            {
                overrideMaterial = _errorMat
            };
            
            for (int n = 1; n < legacyShaderTagIds.Length; n++)
            {
                drawSettings.SetShaderPassName(n, legacyShaderTagIds[n]);        
            }

            var filterSettings = FilteringSettings.defaultValue;
            context.DrawRenderers(_cullingResults, ref drawSettings, ref filterSettings);
        }
    #endif
}
