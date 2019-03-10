using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RopeBinder : Cycle {

  public Life toBind;

  public SDFBoneBuffer bones;
  public float gravity;



  // Use this for initialization
  public override void Bind() {
    toBind.BindForm( "_SDFBoneBuffer" , bones );
    toBind.BindAttribute( "_Gravity" , "gravity" , this );
  }
  


}
