using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SingleTubeVerts: TubeVerts {


  public override void SetStructSize(){ structSize = 16; }

  public override void SetCount(){
    numTubes = hair.numHairs;
    count = numTubes * width * length;
  }

}

