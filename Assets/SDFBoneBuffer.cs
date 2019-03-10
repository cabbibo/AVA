using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SDFBoneBuffer : Form
{

  private float[] values;

  public Transform baseBone;

  public struct boneInfo{
    public Transform start;
    public Transform end;
    public float size;
    public float id;
  }

  public float baseSize;

  public boneInfo[] bones;
  public int boneID = 0;
  //3 start
  //3 end
  //1 size
  //1 debug

  public override void SetStructSize(){ structSize = 8; }

  public override void SetCount(){ 
    percolateNumber( baseBone );
    //count = bones.count; 
    bones = new boneInfo[count];
    values = new float[count * structSize];  
    percolateBoneInfo( baseBone );
  }

  void percolateNumber( Transform t ){
    count += t.childCount;
    for( int i = 0; i < t.childCount; i++ ){
      percolateNumber(t.GetChild(i));
    }
  }

  void percolateBoneInfo( Transform t ){
    for( int i = 0; i < t.childCount; i++ ){
      bones[boneID].start = t;
      bones[boneID].end = t.GetChild(i);
      bones[boneID].id = boneID;


      bones[boneID].size = baseSize;

      if( t.GetComponent<SDFSizeMultiplier>() != null ){
         bones[boneID].size *= t.GetComponent<SDFSizeMultiplier>().sizeMultiplier;
      }
      print(bones[boneID].start);
      boneID ++;
      percolateBoneInfo(t.GetChild(i));
    }
  }

  public override void Embody(){ 

   int index = 0;


    for(int i = 0; i < count; i ++ ){
   
      //print( bones[i].start.position );
      values[index++] = bones[i].start.position.x;
      values[index++] = bones[i].start.position.y;
      values[index++] = bones[i].start.position.z;


      values[index++] = bones[i].end.position.x;
      values[index++] = bones[i].end.position.y;
      values[index++] = bones[i].end.position.z;

      values[index++] = bones[i].size;
      values[index++] = bones[i].id;
    }

    SetData(values);
  }

  public override void WhileLiving( float v ){
    Embody();
  }

  public override void WhileDebug(){
    

    debugMaterial.SetPass(0);
    debugMaterial.SetBuffer("_VertBuffer", _buffer);
    debugMaterial.SetInt("_Count",count);
    Graphics.DrawProcedural(MeshTopology.Triangles, count * 3 * 2 );

  }


}
