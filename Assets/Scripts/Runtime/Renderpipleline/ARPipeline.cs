using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class ARPipeline : RenderPipeline
{
    private CameraRender _cameraRender = new CameraRender();
    private ARPAsset _asset;
    
    public ARPipeline(ARPAsset asset)
    {
        _asset = asset;
        if (_asset.EnableShaderBatch)
        {
            GraphicsSettings.useScriptableRenderPipelineBatching = true;
            Shader.EnableKeyword("ARP_SHADERBATCH_ON");
            //_asset.EnableGPUInstance = false;
            Shader.DisableKeyword("ARP_GPUINSTANCE_ON");
        }/*else if (_asset.EnableGPUInstance)
        {
            GraphicsSettings.useScriptableRenderPipelineBatching = false;
            Shader.DisableKeyword("ARP_SHADERBATCH_ON");
            _asset.EnableShaderBatch = false;
            Shader.EnableKeyword("ARP_GPUINSTANCE_ON");
        }
        else
        {
            GraphicsSettings.useScriptableRenderPipelineBatching = false;
            Shader.DisableKeyword("ARP_GPUINSTANCE_ON");
            Shader.DisableKeyword("ARP_SHADERBATCH_ON");
        }*/
    }


protected override void Render(ScriptableRenderContext context, Camera[] cameras)
    {
        foreach (var cam in cameras)
        {
            if (_cameraRender != null)
            {
                //_cameraRender.Render(ref context, cam, _asset.EnableGPUInstance, _asset.EnableDynamicBathc);
                _cameraRender.Render(ref context, cam, false, _asset.EnableDynamicBathc, _asset.ShadowSettings);
            }
        }
    }
}
