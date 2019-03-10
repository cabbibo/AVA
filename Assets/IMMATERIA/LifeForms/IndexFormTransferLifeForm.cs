using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class IndexFormTransferLifeForm :TransferLifeForm{

  public IndexForm skeletonTris;

  public override void Bind(){

    transfer.BindForm("_SkeletonTriangleBuffer" , skeletonTris );
    
  }



}

