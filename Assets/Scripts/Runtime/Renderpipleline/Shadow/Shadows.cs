using System.Collections;
using System.Collections.Generic;
using System.Data;
using UnityEngine;
using UnityEngine.Rendering;

public class Shadows
{
    private const string bufferName = "Shadow Buffer";
    private const int MaxDirectionalShadow = 1;

    private CommandBuffer _shadowBuffer = new CommandBuffer()
    {
        name = bufferName
    };

    private ScriptableRenderContext _context;
    private CullingResults _cullingResults;
    private ShadowSettings _shadowSettings;
    
    //DirectionalShadow
    private int _directionalShadowCount;
    
    
    struct DirectionalShadow
    {
        public int visibleLightIndex;
    }

    private DirectionalShadow[] _directionalShadows = new DirectionalShadow[MaxDirectionalShadow];

    public void Setup(ScriptableRenderContext context, CullingResults cullingResults, ShadowSettings shadowSettings)
    {
        _context = context;
        _cullingResults = cullingResults;
        _shadowSettings = shadowSettings;

        _directionalShadowCount = 0;
    }
    
    void ExecuteBuffer()
    {
        _context.ExecuteCommandBuffer(_shadowBuffer);
        _shadowBuffer.Clear();
    }

    public void SetupDirectionalShadows(Light light, int lightIndex)
    {
        if (_directionalShadowCount >= MaxDirectionalShadow || light.shadows == LightShadows.None || light.shadowStrength <= 0 
            || !_cullingResults.GetShadowCasterBounds(lightIndex, out Bounds b))
        {
            return;
        }
        
        DirectionalShadow directionalShadow = new DirectionalShadow();
        directionalShadow.visibleLightIndex = lightIndex;

        _directionalShadows[_directionalShadowCount++] = directionalShadow;
    }
}
