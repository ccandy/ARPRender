using System.Collections;
using System.Collections.Generic;
using System.Data;
using Unity.Collections;
using UnityEditor.Rendering;
using UnityEngine;
using UnityEngine.Rendering;

public class Shadows
{
    
    //Shader PropertyID
    private static int dirShadowAtlasId = Shader.PropertyToID("_DirectionalShadowAtlas");
    
    private const string bufferName = "Shadow Buffer";
    private const int MaxDirectionalShadow = 1;
    
    private CommandBuffer _shadowBuffer = new CommandBuffer()
    {
        name = bufferName
    };

    private ScriptableRenderContext _context;
    private CullingResults _cullingResults;
    private ShadowSettings _shadowSettings;
    
    //DirectionalShadow
    private int _directionalShadowCount;
    
    
    struct DirectionalShadow
    {
        public int visibleLightIndex;
    }

    private DirectionalShadow[] _directionalShadows = new DirectionalShadow[MaxDirectionalShadow];

    public void Setup(ScriptableRenderContext context, CullingResults cullingResults, ShadowSettings shadowSettings)
    {
        _context = context;
        _cullingResults = cullingResults;
        _shadowSettings = shadowSettings;

        _directionalShadowCount = 0;
    }

    public void Render()
    {
        if (_directionalShadowCount > 0)
        {
            RenderDirectionalShadows();
        }
        else
        {
            _shadowBuffer.GetTemporaryRT(dirShadowAtlasId, 1,1, 24,FilterMode.Bilinear,RenderTextureFormat.Shadowmap);
        }
    }

    private void RenderDirectionalShadows()
    {
        int altasSize = (int)_shadowSettings.DirecionalShadowSetting.AltasSize;
        _shadowBuffer.GetTemporaryRT(dirShadowAtlasId, altasSize,altasSize, 24, FilterMode.Bilinear, RenderTextureFormat.Shadowmap);
        _shadowBuffer.SetRenderTarget(dirShadowAtlasId, RenderBufferLoadAction.DontCare, RenderBufferStoreAction.Store);
        _shadowBuffer.ClearRenderTarget(true, false, Color.clear);
        _shadowBuffer.BeginSample(bufferName);
        ExecuteBuffer();

        for (int n = 0; n < MaxDirectionalShadow; n++)
        {
            RenderDirectionalShadow(n, (int)_shadowSettings.DirecionalShadowSetting.AltasSize);
        }
        _shadowBuffer.EndSample(bufferName);
        ExecuteBuffer();

    }
    
    private void RenderDirectionalShadow(int lightIndex, int tileSize)
    {
        NativeArray<VisibleLight> visibleLights = _cullingResults.visibleLights;
        DirectionalShadow directionalShadow = _directionalShadows[lightIndex];
        int vlightIndex = directionalShadow.visibleLightIndex;
        VisibleLight visibleLight = visibleLights[directionalShadow.visibleLightIndex];

        var shadowSetting = new ShadowDrawingSettings(_cullingResults, vlightIndex);
        _cullingResults.ComputeDirectionalShadowMatricesAndCullingPrimitives(vlightIndex, 0, 1, Vector3.zero, tileSize,
            0f, out Matrix4x4 viewMatrix, out Matrix4x4 projMatrix, out ShadowSplitData splitData);
        shadowSetting.splitData = splitData;
        _shadowBuffer.SetViewProjectionMatrices(viewMatrix, projMatrix);
        ExecuteBuffer();
        _context.DrawShadows(ref shadowSetting);
    }
    void ExecuteBuffer()
    {
        _context.ExecuteCommandBuffer(_shadowBuffer);
        _shadowBuffer.Clear();
    }

    public void SetupDirectionalShadows(Light light, int lightIndex)
    {
        if (_directionalShadowCount >= MaxDirectionalShadow || light.shadows == LightShadows.None || light.shadowStrength <= 0 
            || !_cullingResults.GetShadowCasterBounds(lightIndex, out Bounds b))
        {
            return;
        }
        
        DirectionalShadow directionalShadow = new DirectionalShadow();
        directionalShadow.visibleLightIndex = lightIndex;

        _directionalShadows[_directionalShadowCount++] = directionalShadow;
    }

    public void CleanUp()
    {
        _shadowBuffer.ReleaseTemporaryRT(dirShadowAtlasId);
        _context.ExecuteCommandBuffer(_shadowBuffer);
        _shadowBuffer.Clear();
    }
    
    
    
}
