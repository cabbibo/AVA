using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class FernTransferTris : IndexForm {

  public override void SetCount(){ count = toIndex.count; }

  public override void Embody(){

    int[] values = new int[count];
    int index = 0;

    for( int i = 0; i < count; i++ ){
        values[ index ++ ] = i;
    }
    SetData(values);
  }

}

