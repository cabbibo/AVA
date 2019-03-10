using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rope: Hair {


  public override void SetCount(){
    numHairs = baseForm.count/2;
    count = numHairs * numVertsPerHair; 
  }




}

