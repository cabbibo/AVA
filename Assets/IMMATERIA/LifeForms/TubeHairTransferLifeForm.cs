using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TubeHairTransferLifeForm : TransferLifeForm {
	
 
  
  public override void Bind(){
    transfer.BindAttribute( "_TubeWidth" , "width" , verts );
    transfer.BindAttribute( "_TubeLength" , "length" , verts );
    transfer.BindAttribute( "_TubeRadius" , "radius" , this );
    transfer.BindAttribute( "_NumVertsPerHair" , "numVertsPerHair" , skeleton );
  }

}
