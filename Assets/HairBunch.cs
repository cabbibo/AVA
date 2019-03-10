using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HairBunch : Hair
{
    
  public int hairsPerPoint;
  
  public override void SetCount(){
    numHairs = baseForm.count * hairsPerPoint;
    count = numHairs * numVertsPerHair; 
  }
}
