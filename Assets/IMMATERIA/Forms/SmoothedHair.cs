using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SmoothedHair : Hair {

  public Hair hairToSmooth;

  public override void SetCount(){
    numHairs = hairToSmooth.numHairs;
    count = numHairs * numVertsPerHair; 
  }

}
