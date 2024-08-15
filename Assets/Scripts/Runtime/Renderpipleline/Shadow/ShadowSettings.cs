using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[System.Serializable]
public class ShadowSettings
{
   [Min(0f)] public float MaxShadowDistance = 10;
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
   }

   public DirecionalShadow DirecionalShadowSetting = new DirecionalShadow
   {
      AltasSize = ShadowMapSize._1024
   };

}
