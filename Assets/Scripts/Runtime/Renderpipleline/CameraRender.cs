using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class CameraRender
{
    private ScriptableRenderContext context;
    private Camera _camera;

    public void Render(ref ScriptableRenderContext context, Camera camera)
    {
        this.context = context;
        this._camera = camera;
    }


}
