using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HairBunchBinder : Cycle {

  public Life setLife;
  public Life simLife;

  public HairBunch hairBunch;

  public float _BunchOutForce;


  // Use this for initialization
  public override void Bind() {
    setLife.BindAttribute( "_HairsPerPoint" , "hairsPerPoint" , hairBunch );
    simLife.BindAttribute( "_HairsPerPoint" , "hairsPerPoint" , hairBunch );
    simLife.BindAttribute( "_BunchOutForce" , "_BunchOutForce" , this );
  }
  


}
