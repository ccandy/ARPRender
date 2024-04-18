using System.Collections;
using System.Collections.Generic;
using System.Data.SqlTypes;
using UnityEngine;
using UnityEngine.Rendering;
[CreateAssetMenu(menuName = "Rendering/ARPAsset")]
public class ARPAsset : RenderPipelineAsset
{
    public bool EnableShaderBatch = true;
    public bool EnableGPUInstance = false;
    public bool EnableDynamicBathc = false;
    protected override RenderPipeline CreatePipeline()
    {
        return new ARPipeline(this);
    }
}
