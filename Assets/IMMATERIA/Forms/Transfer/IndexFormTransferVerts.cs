using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class IndexFormTransferVerts: Form {


  public IndexForm triangles;
  public override void SetStructSize(){ structSize = 16; }

  public override void SetCount(){
    // 0-1
    // |/|
    // 2-3
    count = triangles.count * 4;
  }

}

