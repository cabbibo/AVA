using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MutatingMesh : Form {

  public Mesh m;
  
  struct Vert{
    public Vector3 pos;
    public Vector3 nor;
    public Vector3 tan;
    public Vector2 uv;
    public float debug;
  };

  public override void SetStructSize(){ structSize = 12; }

  public override void SetCount(){ 
    count = m.vertices.Length;
  }

  void WhileMutate(){


    Vector3[] verts = m.vertices;
    Vector2[] uvs = m.uv;
    Vector4[] tans = m.tangents;
    Vector3[] nors = m.normals;
    BoneWeight[] weights = m.boneWeights;


    int index = 0;


   /* Vector3 pos;
    Vector3 uv;
    Vector3 tan;
    Vector3 nor;
    int baseTri;*/

    float[] values = new float[count*structSize];
    for( int i = 0; i < count; i ++ ){
      values[ index ++ ] = verts[i].x;
      values[ index ++ ] = verts[i].y;
      values[ index ++ ] = verts[i].z;

      values[ index ++ ] = nors[i].x;
      values[ index ++ ] = nors[i].y;
      values[ index ++ ] = nors[i].z;

      values[ index ++ ] = 0;
      values[ index ++ ] = 0;
      values[ index ++ ] = 0;

      values[ index ++ ] = uvs[i].x;
      values[ index ++ ] = uvs[i].y;

      values[ index ++ ] = (float)i/(float)count;
    }
    SetData( values );
  }
}