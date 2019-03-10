
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;

public class MeshOnHair : TransferLifeForm {

  public MeshVerts baseVerts;
  public MeshTris baseTris;
  public float _MeshSizeMultiplier;
  public float _MeshLength;

  public override void Bind(){

    transfer.BindAttribute("_NumVertsPerHair", "numVertsPerHair" , skeleton );
    transfer.BindForm("_BaseBuffer", baseVerts );
    transfer.BindAttribute("_MeshSizeMultiplier" , "_MeshSizeMultiplier" , this );
    transfer.BindAttribute("_MeshLength" , "_MeshLength" , this );

  }



}