using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class ARPipeline : RenderPipeline
{
    private CameraRender _cameraRender = new CameraRender();
    protected override void Render(ScriptableRenderContext context, Camera[] cameras)
    {
        foreach (var cam in cameras)
        {
            if (_cameraRender != null)
            {
                _cameraRender.Render(ref context, cam);
            }
        }
    }
    
    
    
}
