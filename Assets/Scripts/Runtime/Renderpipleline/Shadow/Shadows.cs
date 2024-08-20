using Unity.Collections;
using UnityEngine;
using UnityEngine.Rendering;

public class Shadows
{
    private const string bufferName = "Shadow Buffer";

    private const int
        MaxDirectionalShadow = 4,
        MaxCasacde = 4;
    
    //Shader PropertyID
    private static int
        dirShadowAtlasId = Shader.PropertyToID("_DirectionalShadowAtlas"),
        dirShadowMatricsId = Shader.PropertyToID("_DirectonalShadowMatrics"),
        dirShadowDataId = Shader.PropertyToID("_DirectonalShadowData"),
        cascadeCountId = Shader.PropertyToID("_CascadeCount"),
        cascadeSphereCullingSphereId = Shader.PropertyToID("_CascadeSphereCullingSphere"),
        shadowDistanceId = Shader.PropertyToID("_ShadowDistance");
    
    //Shadow Data
    private Matrix4x4[] _dirShadowMatrics = new Matrix4x4[MaxDirectionalShadow * MaxCasacde];
    private Vector4[] _cascadeCullingSpheres = new Vector4[MaxCasacde];
    
    private CommandBuffer _shadowBuffer = new CommandBuffer()
    {
        name = bufferName
    };

    private ScriptableRenderContext _context;
    private CullingResults _cullingResults;
    private ShadowSettings _shadowSettings;
    
    //DirectionalShadow
    private int _directionalShadowCount;
    private int _cascadeCount;
    
    struct DirectionalShadow
    {
        public int visibleLightIndex;
    }

    private DirectionalShadow[] _directionalShadows = new DirectionalShadow[MaxDirectionalShadow];
    private Vector4[] _directionalShadowData = new Vector4[MaxDirectionalShadow];

    public void Setup(ScriptableRenderContext context, CullingResults cullingResults, ShadowSettings shadowSettings)
    {
        _context = context;
        _cullingResults = cullingResults;
        _shadowSettings = shadowSettings;
        _directionalShadowCount = 0;
    }

    public void Render()
    {
        if (_directionalShadowCount > 0)
        {
            RenderDirectionalShadows();
        }
        else
        {
            _shadowBuffer.GetTemporaryRT(dirShadowAtlasId, 1,1, 24,FilterMode.Bilinear,RenderTextureFormat.Shadowmap);
        }
    }

    private RenderTextureFormat GetFormatForShadowMap()
    {
        if (SystemInfo.SupportsRenderTextureFormat(RenderTextureFormat.Shadowmap))
        {
            return RenderTextureFormat.Shadowmap;
        }
        else
        {
            return RenderTextureFormat.Depth;
        }
    }

    private void RenderDirectionalShadows()
    {
        int altasSize = (int)_shadowSettings.DirecionalShadowSetting.AltasSize;
        RenderTextureFormat format = GetFormatForShadowMap();
        _shadowBuffer.GetTemporaryRT(dirShadowAtlasId, altasSize,altasSize, 24, FilterMode.Bilinear, format);
        
        _shadowBuffer.SetRenderTarget(dirShadowAtlasId, RenderBufferLoadAction.DontCare, RenderBufferStoreAction.Store);
        _shadowBuffer.ClearRenderTarget(true, false, Color.clear);
        _shadowBuffer.BeginSample(bufferName);
        ExecuteBuffer();

        int tiles = _directionalShadowCount * _shadowSettings.DirecionalShadowSetting.CascadeCount;
        int split = tiles <= 1 ? 1 : tiles <= 4 ? 2 : 4;
        int tileSize = (int)_shadowSettings.DirecionalShadowSetting.AltasSize / split;
        int shadowCount = Mathf.Min(_directionalShadowCount, MaxDirectionalShadow);
        int casacdeCount = _shadowSettings.DirecionalShadowSetting.CascadeCount;
        Vector3 ratios = _shadowSettings.DirecionalShadowSetting.CasccdeRation;
        
        NativeArray<VisibleLight> visibleLights = _cullingResults.visibleLights;
        for (int n = 0; n < shadowCount; n++)
        {
            DirectionalShadow directionalShadow = _directionalShadows[n];
            int vlightIndex = directionalShadow.visibleLightIndex;
            Light vLight = visibleLights[vlightIndex].light;
            RenderDirectionalShadow(n, tileSize, split, vlightIndex, vLight, casacdeCount, ratios);
        }
        _shadowBuffer.SetGlobalMatrixArray(dirShadowMatricsId, _dirShadowMatrics);
        _shadowBuffer.SetGlobalInt(cascadeCountId, casacdeCount);
        _shadowBuffer.SetGlobalVectorArray(dirShadowDataId, _directionalShadowData);
        _shadowBuffer.SetGlobalVectorArray(cascadeSphereCullingSphereId, _cascadeCullingSpheres);
        _shadowBuffer.SetGlobalFloat(shadowDistanceId, _shadowSettings.MaxShadowDistance);
        _shadowBuffer.EndSample(bufferName);
        ExecuteBuffer();
    }
    
    private void RenderDirectionalShadow(int lightIndex, int tileSize, int split, int vlightIndex, Light light, int cascadeCount, Vector3 ratio)
    {
        var shadowSetting = new ShadowDrawingSettings(_cullingResults, vlightIndex);
        int tileOffset = lightIndex * cascadeCount;
        
        for(int n = 0; n < cascadeCount; n++)
        {
            _cullingResults.ComputeDirectionalShadowMatricesAndCullingPrimitives(vlightIndex, n,
                cascadeCount, ratio, tileSize,
                0f, out Matrix4x4 viewMatrix, out Matrix4x4 projMatrix, out ShadowSplitData splitData);
            
            if (lightIndex == 0)
            {
                Vector4 cullingSphere = splitData.cullingSphere;
                cullingSphere.w *= cullingSphere.w;
                _cascadeCullingSpheres[n] = cullingSphere;
            }
            
            shadowSetting.splitData = splitData;
            int tileIndex = tileOffset + n;
            Vector2 offset = SetViewPort(tileIndex,split, tileSize);
            Matrix4x4 projVeiwMatrix = projMatrix*viewMatrix;
            _dirShadowMatrics[tileIndex] = ConvertToAltasMatrix(projVeiwMatrix, offset, split);
            _shadowBuffer.SetViewProjectionMatrices(viewMatrix, projMatrix);
            ExecuteBuffer();
            _context.DrawShadows(ref shadowSetting);
        }
        _directionalShadowData[lightIndex].x = light.shadowStrength;
        _directionalShadowData[lightIndex].y = lightIndex;
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

    public void CleanUp()
    {
        _shadowBuffer.ReleaseTemporaryRT(dirShadowAtlasId);
        _context.ExecuteCommandBuffer(_shadowBuffer);
        _shadowBuffer.Clear();

        for (int n = 0; n < _dirShadowMatrics.Length; n++)
        {
            _dirShadowMatrics[n] = Matrix4x4.zero;
        }

        for (int n = 0; n < _cascadeCullingSpheres.Length; n++)
        {
            _directionalShadowData[n] = Vector4.zero;
        }
        
    }

    private Vector2 SetViewPort(int index, int split, int tilesize)
    {
        Vector2 offset = new Vector2(index % split, index / split);
        Rect viewRect = new Rect(offset.x * tilesize, offset.y * tilesize, tilesize, tilesize);
        _shadowBuffer.SetViewport(viewRect);
        ExecuteBuffer();

        return offset;
    }

    private Matrix4x4 ConvertToAltasMatrix(Matrix4x4 m, Vector2 offset, int split)
    {
        if (SystemInfo.usesReversedZBuffer) {
            m.m20 = -m.m20;
            m.m21 = -m.m21;
            m.m22 = -m.m22;
            m.m23 = -m.m23;
        }
        float scale = 1f / split;
        m.m00 = (0.5f * (m.m00 + m.m30) + offset.x * m.m30) * scale;
        m.m01 = (0.5f * (m.m01 + m.m31) + offset.x * m.m31) * scale;
        m.m02 = (0.5f * (m.m02 + m.m32) + offset.x * m.m32) * scale;
        m.m03 = (0.5f * (m.m03 + m.m33) + offset.x * m.m33) * scale;
        m.m10 = (0.5f * (m.m10 + m.m30) + offset.y * m.m30) * scale;
        m.m11 = (0.5f * (m.m11 + m.m31) + offset.y * m.m31) * scale;
        m.m12 = (0.5f * (m.m12 + m.m32) + offset.y * m.m32) * scale;
        m.m13 = (0.5f * (m.m13 + m.m33) + offset.y * m.m33) * scale;
        m.m20 = 0.5f * (m.m20 + m.m30);
        m.m21 = 0.5f * (m.m21 + m.m31);
        m.m22 = 0.5f * (m.m22 + m.m32);
        m.m23 = 0.5f * (m.m23 + m.m33);
        return m;
        
    }
    
}
