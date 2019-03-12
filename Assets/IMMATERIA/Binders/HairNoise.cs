using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HairNoise : Cycle {

  public Life toBind;

  public float noiseSize;
  public float noiseSpeed;
  public float noiseForce;
  public float normalForce;
  public float dampening;
  public float upForce;

  public SDFBoneBuffer bones;



  // Use this for initialization
  public override void Bind() {

    toBind.BindForm( "_SDFBoneBuffer" , bones );
    toBind.BindAttribute( "_NoiseSpeed" , "noiseSpeed" , this );
    toBind.BindAttribute( "_NoiseForce" , "noiseForce" , this );
    toBind.BindAttribute( "_NoiseSize" , "noiseSize" , this );
    toBind.BindAttribute( "_NormalForce" , "normalForce" , this );
    toBind.BindAttribute( "_Dampening" , "dampening" , this );
    toBind.BindAttribute( "_UpForce" , "upForce" , this );
    toBind.BindAttribute( "_Gravity" , "upForce" , this );
  }
  


}
