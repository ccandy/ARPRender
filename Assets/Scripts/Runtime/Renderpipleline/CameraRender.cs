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

    
    
    
    public void Render(ref ScriptableRenderContext context, Camera camera)
    {
        this.context = context;
        this._camera = camera;
        PrepareForSceneWindow();
        if (!Cull())
        {
            return;
        }
        
        Setup();
        ExecuteAndClearBuffer();
        DrawVisibleGeometry();
        DrawUnsupportedShaders();
        DrawGizmos();
        Submit();
    }

    void Setup()
    {
        //setup camera matrix
        context.SetupCameraProperties(_camera);

        //setup command buffer
        if (_cameraBuffer == null)
        {
            _cameraBuffer = new CommandBuffer
            {
                name = bufferName
            };
        }

        _cameraBuffer.ClearRenderTarget(true, true, Color.clear);
        _cameraBuffer.BeginSample(bufferName);
    }

    void DrawVisibleGeometry()
    {
        var sortingSettings = new SortingSettings(_camera)
        {
            criteria = SortingCriteria.CommonOpaque
        };
        var drawingSetting = new DrawingSettings(unlitShaderTagId, sortingSettings);
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
        context.Submit();
    }

    void ExecuteAndClearBuffer()
    {
        context.ExecuteCommandBuffer(_cameraBuffer);
        _cameraBuffer.Clear();
    }
    
    

}
