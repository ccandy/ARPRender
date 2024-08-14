using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[DisallowMultipleComponent]
public class PreObjectMaterialProperties : MonoBehaviour
{
    private static int baseColorId = Shader.PropertyToID("_Color");
    private static MaterialPropertyBlock _block;

    private Renderer _renderer;
    
    [SerializeField] private Color baseColor = Color.white;
    // Start is called before the first frame update

    private void OnValidate()
    {
        if (_block == null)
        {
            _block = new MaterialPropertyBlock();
        }
        _block.SetColor(baseColorId, baseColor);
        _renderer = gameObject.GetComponent<Renderer>();
        if (_renderer != null)
        {
            _renderer.SetPropertyBlock(_block);
        }
        else
        {
            Debug.LogError("Render is null");
        }

    }

    private void Awake()
    {
        OnValidate();
    }
}
