using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Body : MeshLifeForm {


  [HideInInspector] public MeshRenderer render;
  [HideInInspector] public Mesh mesh;
  [HideInInspector] public MeshFilter filter;

  public bool self;
  
  public Material material;
  public Material debugMaterial;
  private GameObject go;

  private bool oActive;

  public override void _Create(){
    
    if( verts == null ){ verts = GetComponent<MeshVerts>(); }
    if( triangles == null ){ triangles = GetComponent<MeshTris>(); }
    Cycles.Insert(0,verts);
    Cycles.Insert(1,triangles);
    

    SetUpGameObject();
    DoCreate();
    SetUpMesh();
  }

  public override void _WhileLiving(float v ){
    DoLiving(v);

    if( active == true ){
      Show();
    }
    
    if( active && oActive == false ){
      Show();
    }else if( oActive && active == false){
      Hide();
    }
    //Show();
    oActive = active;
  }

  public virtual void SetUpMesh(){

    mesh.vertices = new Vector3[verts.count];

    if( verts.count > 65000 ){
      mesh.indexFormat = UnityEngine.Rendering.IndexFormat.UInt32;
    }

    int[] tris = new int[triangles.count];
    mesh.triangles = tris;
    mesh.bounds  = new Bounds (Vector3.zero,Vector3.one * 100000);

  }

  public virtual void SetUpGameObject(){
    

    mesh = new Mesh();

    if( self == true ){
      go = this.gameObject;
    }else{
      go = new GameObject();
      go.name = gameObject.name + " : BODY";
      go.transform.parent = gameObject.transform;
    }

    //DebugThis("SET UP BODY ");

    filter = go.AddComponent<MeshFilter>();
    filter.mesh = mesh;

    render = go.AddComponent<MeshRenderer>();
    render.sharedMaterial = material;
    render.enabled = false;



  }

  public override void _OnGestate(){
    DoGestate();
    AssignMesh();
  }

  public virtual void BodyCreate(){}

  public override void Destroy(){
    if( self == false ){ 
      DestroyImmediate(go); 
    }else{
      DestroyImmediate( filter );
      DestroyImmediate( render );
    }
    mesh = null;
    render = null;
  }

  public virtual void AssignMesh(){
    mesh.triangles =  triangles.GetIntData();
    mesh.UploadMeshData(false);
  }

  public void Hide(){
    render.enabled = false;
  }

  public void Show(){
    if( triangles._buffer != null && verts._buffer != null ){
      render.material.SetInt("_TransferCount", verts.count);
      render.material.SetBuffer("_TransferBuffer", verts._buffer );
      render.enabled= true;
    }else{
      print("u got a null buffer! add more info to me to know which one");
    }
  }


 

  public virtual void Bake(){

    float[] data = verts.GetData();
    mesh.vertices = ExtractVerts( data );
    mesh.normals  = ExtractNormals( data );
    mesh.uv       = ExtractUVs( data );

  }

  public virtual Vector3[] ExtractVerts(float[] data){

    Vector3[] v = new Vector3[verts.count];

    int offset = 0;

    Vector3 info;
    for( int i = 0; i < verts.count; i++ ){

      info = new Vector3( data[ i * verts.structSize + offset + 0 ]
                        , data[ i * verts.structSize + offset + 1 ] 
                        , data[ i * verts.structSize + offset + 2 ] );

      v[i] = info;

    }

    return v;
  }

  public virtual Vector3[] ExtractNormals(float[] data){
    
    Vector3[] n = new Vector3[verts.count];     

    int offset = 3;

    if( verts.structSize == 9  ){ offset = 3; }
    if( verts.structSize == 12 ){ offset = 3; }
    if( verts.structSize == 16 ){ offset = 6; }
    if( verts.structSize == 24 ){ offset = 6; }
    if( verts.structSize == 36 ){ offset = 6; }

    Vector3 info;
    
    for( int i = 0; i < verts.count; i++ ){

      info = new Vector3( data[ i * verts.structSize + offset + 0 ]
                        , data[ i * verts.structSize + offset + 1 ] 
                        , data[ i * verts.structSize + offset + 2 ] );

      n[i] = info;

    }

    return n;

  }

  public virtual Vector2[] ExtractUVs(float[] data){

    Vector2[] uv = new Vector2[verts.count];

    int offset = 9;
    if( verts.structSize == 9  ){ offset =  6; }
    if( verts.structSize == 12 ){ offset =  9; }
    if( verts.structSize == 16 ){ offset = 12; }
    if( verts.structSize == 24 ){ offset = 12; }
    if( verts.structSize == 36 ){ offset = 12; }

    Vector2 info;
    for( int i = 0; i < verts.count; i++ ){

      info = new Vector2( data[ i * verts.structSize + offset + 0 ]
                        , data[ i * verts.structSize + offset + 1 ] );

      uv[i] = info;

    }

    return uv;

  }



  public override void WhileDebug(){
    debugMaterial.SetPass(0);
    debugMaterial.SetBuffer("_VertBuffer", verts._buffer);
    debugMaterial.SetBuffer("_TriBuffer", triangles._buffer);
    debugMaterial.SetInt("_Count",triangles.count);
    Graphics.DrawProcedural(MeshTopology.Triangles, triangles.count * 3 * 2 );
  }



}
