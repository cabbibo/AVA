
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SmoothHair : LifeForm {

  public Life smooth;
  public SmoothedHair smoothed;
  public Hair hair;
  public override void Create(){


    Cycles.Insert( 0, smoothed );
    Cycles.Insert( 1, smooth );

}

  public override void Bind(){

    smooth.BindPrimaryForm("_VertBuffer", smoothed);
    smooth.BindForm("_SkeletonBuffer", hair );

    smooth.BindAttribute( "_NumVertsPerHair" , "numVertsPerHair", hair );
    smooth.BindAttribute( "_NumHairs" , "numHairs", hair );
    smooth.BindAttribute( "_SmoothNumVertsPerHair" , "numVertsPerHair", smoothed );


  }



}