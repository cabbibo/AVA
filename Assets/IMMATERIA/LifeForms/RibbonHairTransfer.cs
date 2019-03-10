using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RibbonHairTransfer : TransferLifeForm {
  
   public override void Bind(){
    transfer.BindAttribute( "_RibbonLength" , "length" , verts );
    transfer.BindAttribute( "_NumVertsPerHair" , "numVertsPerHair" , skeleton );
  }

}
