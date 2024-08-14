using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Random = UnityEngine.Random;

public class GenerateBalls : MonoBehaviour
{
    private const int MAX_BALLS = 1023;
    
    private static int baseColorId = Shader.PropertyToID("_Color");

    [SerializeField] private Mesh _mesh = default;
    [SerializeField] private Material _material = default;

    private Matrix4x4[] _matrix4X4s = new Matrix4x4[MAX_BALLS];
    private Vector4[] _baseColors = new Vector4[MAX_BALLS];

    private MaterialPropertyBlock _block;

    private void Awake()
    {
        for (int n = 0; n < MAX_BALLS; n++)
        {
            _matrix4X4s[n] = Matrix4x4.TRS(Random.insideUnitSphere * 10.0f, Quaternion.identity, Vector3.one);
            _baseColors[n] = new Vector4(Random.value, Random.value, Random.value, 1.0f);
        }
    }
    
    // Update is called once per frame
    void Update()
    {
        if (_block == null)
        {
            _block = new MaterialPropertyBlock();
            _block.SetVectorArray(baseColorId, _baseColors);
        }
        Graphics.DrawMeshInstanced(_mesh, 0, _material, _matrix4X4s, MAX_BALLS, _block);
    }
}
