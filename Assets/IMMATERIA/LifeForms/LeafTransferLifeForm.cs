using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LeafTransferLifeForm :TransferLifeForm{

  public LeafVerts leaf;

  public override void Bind(){

    transfer.BindForm("_LeafBuffer" , leaf );
    
  }



}
