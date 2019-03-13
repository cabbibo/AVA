using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GirderVerts : Form
{

  public Form baseVerts;

  public override void SetStructSize(){ structSize = 16; }

  public override void SetCount(){
    count = baseVerts.count * 3 * 4;
  }

}
