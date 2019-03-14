using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Glitch : MonoBehaviour
{

    public bool glitching;
    public float glitchStartTime;
    public float glitchLength;
    public Material glitchMaterial;

    public float upDown;
    public float swipeVal;

    public float glitchPow;


    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {

      glitchPow  = ( Time.time - glitchStartTime ) / glitchLength;
      glitchMaterial.SetFloat("_GlitchPower", glitchPow);
      glitchMaterial.SetFloat("_UpDown", upDown);
      glitchMaterial.SetFloat("_SwipeVal", swipeVal);
      // Copy the source Render Texture to the destination,
      // applying the material along the way.
      Graphics.Blit(source, destination,glitchMaterial);
      
    }
}
