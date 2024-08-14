using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class Lighting
{
    private static int
        dirLightColorId = Shader.PropertyToID("_directionalLightColor"),
        dirLightDirId = Shader.PropertyToID("_directionalLightDir");
    
    
    private const string bufferName = "CustomLight";
    
    private CommandBuffer cmd = new CommandBuffer{
        name = bufferName, 
    };

    public void Setup(ScriptableRenderContext context)
    {
        cmd.BeginSample(bufferName);
        SetupDirectionalLight();
        cmd.EndSample(bufferName);
        context.ExecuteCommandBuffer(cmd);
        cmd.Clear();
    }

    private void SetupDirectionalLight()
    {
        Light light = RenderSettings.sun;
        cmd.SetGlobalVector(dirLightColorId, light.color.linear * light.intensity);
        cmd.SetGlobalVector(dirLightDirId, -light.transform.forward);
    }
    
}
