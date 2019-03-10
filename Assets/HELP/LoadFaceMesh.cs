using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.IO;
using System.Runtime.Serialization.Formatters.Binary;


public class LoadFaceMesh : MonoBehaviour {


  public void Save(Mesh mesh, string name){
    BinaryFormatter bf = new BinaryFormatter();
    FileStream stream = new FileStream(Application.streamingAssetsPath +name+".mesh",FileMode.Create);
    SerializeMesh  m = new SerializeMesh( mesh , name );
    bf.Serialize(stream,m);
    stream.Close();
  }

  public Mesh Load(string name){
    if( File.Exists(Application.streamingAssetsPath +"/"+name+".mesh")){
       BinaryFormatter bf = new BinaryFormatter();
        //FileStream stream = new FileStream(Application.streamingAssetsPath +"/"+name+".mesh",FileMode.OpenRead);
        FileStream stream = File.OpenRead(Application.streamingAssetsPath +"/"+name+".mesh");

        SerializeMesh data = bf.Deserialize(stream) as SerializeMesh;

//        print("loaded");
        stream.Close();
        return data.GetMesh();//data;
    }else{
     // print("nahhh");
      return new Mesh();
    }


  }
  
  // Update is called once per frame
  void Update () {
    
  }
}


[System.Serializable]
class SerializeMesh{

  [SerializeField]
  public float[] vertices;
  [SerializeField]
  public int[] triangles;
  [SerializeField]
  public float[] uvs;
  [SerializeField]
  public float[] normals;

  public SerializeMesh( Mesh m , string name ){

    triangles = new int[ m.triangles.Length];

    vertices  = new float[m.vertices.Length * 3];
    normals  = new float[m.normals.Length * 3];
    uvs       = new float[m.uv.Length * 2];


    Vector3[] verts = m.vertices;
    Vector3[] norm = m.normals;
    Vector2[] uv = m.uv;

    int[] tris = m.triangles;

    int index;

    index = 0;
    for( int i = 0; i < m.vertices.Length; i++ ){
      vertices[index++] = verts[i].x;
      vertices[index++] = verts[i].y;
      vertices[index++] = verts[i].z;
    }

    index = 0;
    for( int i = 0; i < m.normals.Length; i++ ){
      normals[index++] = norm[i].x;
      normals[index++] = norm[i].y;
      normals[index++] = norm[i].z;
    }

    index = 0;
    for( int i = 0; i < m.uv.Length; i++ ){
      uvs[index++] = uv[i].x;
      uvs[index++] = uv[i].y;
    }

    index = 0;
    for( int i = 0; i < m.triangles.Length; i++ ){
      triangles[index++] = tris[i];
    }
    
  }


  public Mesh GetMesh(){


    Mesh m = new Mesh();

    List<Vector3> verticesList = new List<Vector3>();
    for (int i = 0; i < vertices.Length / 3; i++){
        verticesList.Add(new Vector3(vertices[i * 3], vertices[i * 3 + 1], vertices[i * 3 + 2]));
    }
    m.SetVertices(verticesList);

    m.triangles = triangles;

    List<Vector2> uvList = new List<Vector2>();
    for (int i = 0; i < uvs.Length / 2; i++){
      uvList.Add(new Vector2( uvs[i * 2], uvs[i * 2 + 1]));
    }
    m.SetUVs(0, uvList);

    List<Vector3> normalsList = new List<Vector3>();
    for (int i = 0; i < normals.Length / 3; i++) {
      normalsList.Add(new Vector3( normals[i * 3], normals[i * 3 + 1], normals[i * 3 + 2]));
    }
    m.SetNormals(normalsList);

    return m;
  
  }

}