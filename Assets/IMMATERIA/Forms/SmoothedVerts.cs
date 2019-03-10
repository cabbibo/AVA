using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SmoothedVerts :  Hair {
  public override void SetStructSize(){ structSize = 16; }
  public override void SetCount(){ count = numHairs *numVertsPerHair; }
}