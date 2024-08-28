using System.Collections;
using System.Collections.Generic;
using Unity.Collections;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.UI;

public class Lighting
{
    //directional light
    private static int
        dirLightColorId = Shader.PropertyToID("_directionalLightColors"),
        dirLightDirId = Shader.PropertyToID("_directionalLightDirs"),
        dirLightCountId = Shader.PropertyToID("_direcionalLightCount");
    private const int max_dirLight_count = 4;
    private int dirLightCount = 0;
    private Vector4[] dirLightColors = new Vector4[max_dirLight_count];
    private Vector4[] dirLightDirs = new Vector4[max_dirLight_count];
    
    //additional light
    private static int
        additionalLightCountId = Shader.PropertyToID("_additionalLightCount"),
        additionalLightColorsId = Shader.PropertyToID("_additionalLightColors"),
        additionalLightPosId = Shader.PropertyToID("additionalLightPos");
    private const int max_additionallight_count = 64;
    private int additonalLightCount = 0;
    private static Vector4[]
        additionalLightColors = new Vector4[max_additionallight_count],
        additionalPositions = new Vector4[max_additionallight_count];
    
    //buffers
    private const string bufferName = "CustomLight";
    private Shadows _shadows;
    private ShadowSettings _shadowSettings;
    
    private CommandBuffer cmd = new CommandBuffer{
        name = bufferName, 
    };

    public void Setup(ScriptableRenderContext context, ref CullingResults cullingResults, ShadowSettings shadowSettings)
    {
        _shadowSettings = shadowSettings;
        cmd.BeginSample(bufferName);
        NativeArray<VisibleLight> visibleLights = cullingResults.visibleLights;

        if (_shadows == null)
        {
            _shadows = new Shadows();
        }
        _shadows.Setup(context, cullingResults,_shadowSettings);

        SetupLights(context, visibleLights);
        
        _shadows.Render();
        
        cmd.EndSample(bufferName);
        context.ExecuteCommandBuffer(cmd);
        cmd.Clear();
    }

    private void SetupLights(ScriptableRenderContext context, NativeArray<VisibleLight> visibleLights)
    {
        for (int n = 0; n < visibleLights.Length; n++)
        {
            VisibleLight visibleLight = visibleLights[n];

            if (visibleLight.lightType == LightType.Directional)
            {
                SetupDirectionalLight(visibleLight, n);
            }else if (visibleLight.lightType == LightType.Spot || visibleLight.lightType == LightType.Point)
            {
                SetupAdditionalLight(visibleLight, n);
            }
        }

        SetDirLightToGPU();
        SetAdditionalLightToGPU();
        cmd.EndSample(bufferName);
        context.ExecuteCommandBuffer(cmd);
        cmd.Clear();

    }

    private void SetupAdditionalLight(VisibleLight visibleLight, int visibleLightIndex)
    {
        if (additonalLightCount >= max_additionallight_count)
        {
            return;
        }

        additionalLightColors[additonalLightCount] = visibleLight.finalColor;
        if (visibleLight.lightType == LightType.Point)
        {
            SetupPointLight(additonalLightCount, ref visibleLight);
        }
        
        additonalLightCount++;
    }

    private void SetupPointLight(int index, ref VisibleLight visibleLight)
    {
        additionalPositions[index] = visibleLight.localToWorldMatrix.GetColumn(3);
    }
    
    private void SetupDirectionalLight(VisibleLight visibleLight, int visualLightIndex)
    {
        if (dirLightCount >= max_dirLight_count)
        {
            return;
        }

        dirLightColors[dirLightCount] = visibleLight.finalColor;
        dirLightDirs[dirLightCount] = -visibleLight.localToWorldMatrix.GetColumn(2);
        _shadows.SetupDirectionalShadows(visibleLight.light, visualLightIndex);
        dirLightCount++;
    }

    public void ClearLighting()
    {
        dirLightCount = 0;
        for (int n = 0; n < max_dirLight_count; n++)
        {
            dirLightColors[n] = Vector4.zero;
            dirLightDirs[n] = Vector4.zero;
        }
        
        _shadows.CleanUp();
    }

    private void SetDirLightToGPU()
    {
        if (dirLightCount > 0)
        {
            cmd.SetGlobalVectorArray(dirLightColorId, dirLightColors);
            cmd.SetGlobalVectorArray(dirLightDirId, dirLightDirs);
            cmd.SetGlobalFloat(dirLightCountId, dirLightCount);
        }
    }

    private void SetAdditionalLightToGPU()
    {
        if (additonalLightCount > 0)
        {
            cmd.SetGlobalFloat(additionalLightCountId, additonalLightCount);
            cmd.SetGlobalVectorArray(additionalLightColorsId, additionalLightColors);
            cmd.SetGlobalVectorArray(additionalLightPosId, additionalPositions);
        }
    }
    
}
