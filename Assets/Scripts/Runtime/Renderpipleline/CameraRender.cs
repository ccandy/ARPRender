using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class CameraRender
{
    private const string bufferName = "Render Camera";
    private CommandBuffer _cameraBuffer;
    private ScriptableRenderContext context;
    private Camera _camera;

    public void Render(ref ScriptableRenderContext context, Camera camera)
    {
        this.context = context;
        this._camera = camera;
        
        Setup();
        ExecuteAndClearBuffer();
        DrawVisibleGeometry();
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
        context.DrawSkybox(_camera);
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
