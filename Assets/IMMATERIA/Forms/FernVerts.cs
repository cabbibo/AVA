﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FernVerts : Form {

  public int vertsPerVert;
  public Form stem;
  public Material lineDebugMaterial;

  public override void SetStructSize(){ structSize = 16; }
  public override void SetCount(){ count = stem.count * vertsPerVert; }


  public override void WhileDebug(){

    
    lineDebugMaterial.SetPass(0);
    lineDebugMaterial.SetBuffer("_VertBuffer", _buffer);
    lineDebugMaterial.SetBuffer("_SkeletonBuffer", stem._buffer);
    lineDebugMaterial.SetInt("_Count",count);
    lineDebugMaterial.SetInt("_VertsPerVert",vertsPerVert);
    lineDebugMaterial.SetInt("_StemCount",stem.count);
    Graphics.DrawProcedural(MeshTopology.Lines, count  * 2 );

    debugMaterial.SetPass(0);
    debugMaterial.SetBuffer("_VertBuffer", _buffer);
    debugMaterial.SetInt("_Count",count);
    Graphics.DrawProcedural(MeshTopology.Triangles, count * 3 * 2 );

  }




}
