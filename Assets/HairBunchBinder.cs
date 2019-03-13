using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HairBunchBinder : Cycle {

  public Life setLife;
  public Life simLife;


  public HairBunch hairBunch;
  
  public SDFBoneBuffer bones;

  public float _BunchOutForce;
  public float _NoiseSize;
  public float _NoiseSpeed;
  public float _NoiseForce;
  public float _NormalForce;
  public float _Dampening;
  public float _UpForce;

  // Use this for initialization
  public override void Bind() {
    setLife.BindAttribute( "_HairsPerPoint" , "hairsPerPoint" , hairBunch );
    simLife.BindAttribute( "_BunchOutForce" , "_BunchOutForce" , this );


    simLife.BindAttribute( "_NoiseSize" , "_NoiseSize" , this );
    simLife.BindAttribute( "_NoiseSpeed" , "_NoiseSpeed" , this );
    simLife.BindAttribute( "_NoiseForce" , "_NoiseForce" , this );
    simLife.BindAttribute( "_NormalForce" , "_NormalForce" , this );
    simLife.BindAttribute( "_Dampening" , "_Dampening" , this );
    simLife.BindAttribute( "_UpForce" , "_UpForce" , this );

    simLife.BindForm( "_SDFBoneBuffer" , bones );
  }
  


}
