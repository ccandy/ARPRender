using System.Collections;
using System.Collections.Generic;
using System.Data.SqlTypes;
using UnityEngine;
using UnityEngine.Rendering;
[CreateAssetMenu(menuName = "Rendering/ARPAsset")]
public class ARPAsset : RenderPipelineAsset
{
    protected override RenderPipeline CreatePipeline()
    {
        return new ARPipeline();
    }
}
