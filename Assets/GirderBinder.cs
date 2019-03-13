using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GirderBinder : Cycle
{
  public Life toBind;

  public float _GirderLength;
  public float _GirderWidth;

  public override void Bind(){
    toBind.BindAttribute("_GirderLength" , "_GirderLength" , this);
    toBind.BindAttribute("_GirderWidth" , "_GirderWidth" , this);
  }
}
