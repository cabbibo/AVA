using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GemVerts : Form
{

  public Form baseVerts;
  public int numSidesOfGem;

  public override void SetStructSize(){ structSize = 16; }

  public override void SetCount(){
    count = baseVerts.count * ( numSidesOfGem + 2 );
  }

}
