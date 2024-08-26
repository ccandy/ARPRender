using System;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting.FullSerializer.Internal.Converters;
using UnityEditor.PackageManager.UI;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.UI;

public partial class CameraRender
{
    private const string bufferName = "Render Camera";
    private CommandBuffer _cameraBuffer;
    private ScriptableRenderContext context;
    private Camera _camera;

    private CullingResults _cullingResults;

    private Lighting _lighting = new Lighting();
    private ShadowSettings _shadowSettings;
    
    
    public void Render(ref ScriptableRenderContext context, Camera camera, bool useGPUInstance, bool useDynamicBatch, ShadowSettings shadowSettings)
    {
        this.context = context;
        this._camera = camera;
        _shadowSettings = shadowSettings;
        PrepareBuffer();
        PrepareForSceneWindow();
        if (!Cull(_shadowSettings.MaxShadowDistance))
        {
            return;
        }

        BeginSample();
        _lighting.Setup(context, ref _cullingResults, shadowSettings);
        EndSample();
        Setup();
        ExecuteAndClearBuffer();
        DrawVisibleGeometry(useGPUInstance, useDynamicBatch);
        DrawUnsupportedShaders();
        DrawGizmos();
        CleanUP();
        Submit();
       

    }

    private void CleanUP()
    {
        _lighting.ClearLighting();
    }
    
    void Setup()
    {
        //setup camera matrix
        context.SetupCameraProperties(_camera);
        CameraClearFlags flags = _camera.clearFlags;
        _cameraBuffer.ClearRenderTarget(flags <= CameraClearFlags.Depth, 
            flags == CameraClearFlags.Color,
            flags == CameraClearFlags.Color ?
            _camera.backgroundColor.linear : Color.clear);
        BeginSample();
    }

    void DrawVisibleGeometry(bool useGPUInstance, bool useDynamicBatch)
    {
        var sortingSettings = new SortingSettings(_camera)
        {
            criteria = SortingCriteria.CommonOpaque
        };
        var drawingSetting = new DrawingSettings(unlitShaderTagId, sortingSettings)
        {
            enableInstancing = useGPUInstance,
            enableDynamicBatching = useDynamicBatch,
            perObjectData = PerObjectData.Lightmaps | PerObjectData.LightProbe
        };
        drawingSetting.SetShaderPassName(1,litShaderTagId);
        var filteringSetting = new FilteringSettings(RenderQueueRange.opaque);
        
        context.DrawRenderers(_cullingResults, ref drawingSetting, ref filteringSetting);
        
        context.DrawSkybox(_camera);

        sortingSettings.criteria = SortingCriteria.CommonTransparent;
        drawingSetting.sortingSettings = sortingSettings;
        filteringSetting.renderQueueRange = RenderQueueRange.transparent;
        
        context.DrawRenderers(_cullingResults, ref drawingSetting, ref filteringSetting);
    }

    
    
    bool Cull(float shadowDistance)
    {
        if (_camera.TryGetCullingParameters(out ScriptableCullingParameters parameters))
        {
            parameters.shadowDistance = Mathf.Min(shadowDistance, _camera.farClipPlane);
            _cullingResults = context.Cull(ref parameters);
            return true;
        }

        return false;
    }

    private void BeginSample()
    {
        _cameraBuffer.BeginSample(bufferName);
        ExecuteAndClearBuffer();
    }

    private void EndSample()
    {
        _cameraBuffer.EndSample(bufferName);
        ExecuteAndClearBuffer();
    } 
    
    private void Submit()
    {
        _cameraBuffer.EndSample(bufferName);
        ExecuteAndClearBuffer();
        context.Submit();
    }

    private void ExecuteAndClearBuffer()
    {
        context.ExecuteCommandBuffer(_cameraBuffer);
        _cameraBuffer.Clear();
    }
    
    

}
