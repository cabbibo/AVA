
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SmoothVerts : LifeForm {

  public Life smooth;
  public SmoothedVerts smoothed;
  public Form skeleton;
  
  public override void Create(){
    Cycles.Insert(0, smooth );
    Cycles.Insert(1, smoothed );
  }

  public override void Bind(){
    smooth.BindPrimaryForm("_VertBuffer", smoothed);
    smooth.BindForm("_SkeletonBuffer", skeleton );
  }

}