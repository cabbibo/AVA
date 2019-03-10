using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ParticleTransferVerts: Form {


  public Form particles;
  public override void SetStructSize(){ structSize = 16; }

  public override void SetCount(){
    // 0-1
    // |/|
    // 2-3
    count = particles.count * 4;
  }

}



