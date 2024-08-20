using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[System.Serializable]
public class ShadowSettings
{
   [Min(0.0001f)] public float MaxShadowDistance = 10;
   [Range(0.001f, 1f)] public float DistanceFade = 0.1f;
   
   public enum ShadowMapSize
   {
      _256 = 256,
      _512 = 512,
      _1024 = 1024,
      _2048 = 2048
   }
   
   [System.Serializable]
   public struct DirecionalShadow
   {
      public ShadowMapSize AltasSize;
      [Range(1, 4)] public int CascadeCount;
      [Range(0, 1f)] public float CasccdeRation1, CasccdeRation2, CasccdeRation3;
      public Vector3 CasccdeRation => new Vector3(CasccdeRation1, CasccdeRation2, CasccdeRation3);
   }
   
   public DirecionalShadow DirecionalShadowSetting = new DirecionalShadow
   {
      AltasSize = ShadowMapSize._1024,
      CascadeCount = 4,
      CasccdeRation1 = 0.1f,
      CasccdeRation2 = 0.25f,
      CasccdeRation3 = 0.5f
   };

   

}
