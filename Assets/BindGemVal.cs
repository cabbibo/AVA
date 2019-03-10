using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BindGemVal : Cycle
{
  public Life toBind;
  public GemVerts verts;

  public override void Bind(){
    toBind.BindAttribute("_VertsPerGem" , "numSidesOfGem" , verts);
  }
}
