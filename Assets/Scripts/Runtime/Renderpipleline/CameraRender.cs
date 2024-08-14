using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public partial class CameraRender
{
    private const string bufferName = "Render Camera";
    private CommandBuffer _cameraBuffer;
    private ScriptableRenderContext context;
    private Camera _camera;

    private CullingResults _cullingResults;

    private Lighting _lighting = new Lighting();
    
    public void Render(ref ScriptableRenderContext context, Camera camera, bool useGPUInstance, bool useDynamicBatch)
    {
        this.context = context;
        this._camera = camera;
        PrepareBuffer();
        PrepareForSceneWindow();
        if (!Cull())
        {
            return;
        }
        
        Setup();
        _lighting.Setup(context);
        ExecuteAndClearBuffer();
        DrawVisibleGeometry(useGPUInstance, useDynamicBatch);
        DrawUnsupportedShaders();
        DrawGizmos();
        Submit();
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
        _cameraBuffer.BeginSample(bufferName);
        ExecuteAndClearBuffer();
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
            enableDynamicBatching = useDynamicBatch
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

    
    
    bool Cull()
    {
        if (_camera.TryGetCullingParameters(out ScriptableCullingParameters parameters))
        {
            _cullingResults = context.Cull(ref parameters);
            return true;
        }

        return false;
    }
    
    void Submit()
    {
        _cameraBuffer.EndSample(bufferName);
        ExecuteAndClearBuffer();
        context.Submit();
    }

    void ExecuteAndClearBuffer()
    {
        context.ExecuteCommandBuffer(_cameraBuffer);
        _cameraBuffer.Clear();
    }
    
    

}
