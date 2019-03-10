using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GemTris : IndexForm
{

  [HideInInspector]public int numSidesOfGem;
  [HideInInspector]public int baseCount;
  
  public override void SetCount(){
      baseCount = ((GemVerts)toIndex).baseVerts.count;
      numSidesOfGem = ((GemVerts)toIndex).numSidesOfGem;
    count = baseCount * numSidesOfGem * 3 * 2 ;
  }

  public override void Embody(){

    int[] values = new int[count];
    int index = 0;
    int bID;


    for( int i = 0; i < baseCount; i++ ){
    for( int j = 0; j < numSidesOfGem; j++ ){
     
      bID = i * (numSidesOfGem+2);

      values[ index ++ ] = bID + j ;
      values[ index ++ ] = bID + ((j +1)%numSidesOfGem);
      values[ index ++ ] = bID + numSidesOfGem ;

      values[ index ++ ] = bID + j ;
      values[ index ++ ] = bID + ((j +1)%numSidesOfGem);
      values[ index ++ ] = bID + numSidesOfGem+1;

    }}

    SetData(values);

  }
}
