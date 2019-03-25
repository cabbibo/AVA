using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlaceParticlesOnMesh : LifeForm {


  public bool drawable;
  public bool dragDraw;


  public PlacedDynamicMeshParticles particles;
  public Life place;
  //public CalcLife intersect;


  public string fileName;
  public Vector3 cameraUp;
  public Vector3 cameraLeft;
  public float radius;
  public float[] transformFloats;

  public int test;

  public TouchToRay touch;
  public Tracer trace;

  public Body skin;
  public Mesh mesh;

  public Saveable saver;

  public int currentID;
  public int oldID;

  public Vector3 LastHitPoint;
  public Vector3 CurrentHitPoint;

  public float minDist;


  // Use this for initialization
  public override void _Create(){

    touch = Camera.main.GetComponent<TouchToRay>();

    Cycles.Insert(0,place);

//    Cycles.Insert(0,intersect);
    
    Cycles.Insert(0,particles);

    //print("insetring");
    
    if( mesh == null ){ mesh = skin.gameObject.GetComponent<MeshFilter>().mesh; }
  
    DoCreate();

  }

  public override void Bind(){

    place.BindPrimaryForm("_VertBuffer",particles);
    place.BindForm("_SkinnedBuffer",skin.verts);
    place.BindAttribute("_Transform" , "transformFloats" , this );

    //intersect.BindForm("_ParticleBuffer",particles);
    //intersect.BindForm("_SkinnedVertBuffer",skin.verts);
    //intersect.BindPrimaryForm("_SkinnedTriBuffer",skin.triangles);
    //intersect.BindAttribute("_RO"  , "RayOrigin" , touch );
    //intersect.BindAttribute("_RD"  , "RayDirection" , touch );
    //
    //intersect.BindAttribute("_Transform" , "transformFloats" , this ); 


  }


  public override void OnGestated(){
//    print( particles._buffer);
    particles.Embody( mesh );
  }
  
  public override void OnBirth(){
   // body.Show();
  }

  public override void WhileLiving(float v){


    if( active == true ){
      // print(Camera.main);
      cameraLeft = -Camera.main.transform.right;
      cameraUp = Camera.main.transform.up;
      transformFloats = HELP.GetMatrixFloats(skin.gameObject.transform.worldToLocalMatrix);
//      print( transformFloats);

      if( drawable == true ){
        if( touch.JustDown == 1  ){
          CheckForNew();// SetParticle( trace , currentID ,  )
        }

        if( dragDraw ){
          if( touch.Down == 1 ){
            CheckForNew();
          }
        }
      }
    
    }

  }

  public void CheckForNew(){
    if( trace.down ){
      LastHitPoint = CurrentHitPoint;
      CurrentHitPoint = trace.hitPoint;
      if( LastHitPoint != CurrentHitPoint ){
      Vector3 dist = LastHitPoint - CurrentHitPoint;
      if( dist.magnitude > minDist ){
        SetParticleInfo( currentID );
        currentID ++;
        currentID %= particles.count;
        

      }}

    }else{
      //print("trace not hit");
    }

  }


  public void Clear(){
    float[] values = new float[particles.count * particles.structSize];
    particles.SetData( values ); 
  }

  void SetParticleInfo(int id){
    float[] values = new float[particles.structSize];

   /* struct Particle{
  float3 pos;
  float3 vel;
  float3 nor;
  float3 tang;
  float2 uv;
  float used;
  float3 triIDs;
  float3 triWeights;
  float3 debug;
};*/
    values[0] = trace.hitPoint.x;
    values[1] = trace.hitPoint.y;
    values[2] = trace.hitPoint.z;

    values[3] = 0;
    values[4] = 0;
    values[5] = 0;

    values[6] = trace.hitNormal.x;
    values[7] = trace.hitNormal.y;
    values[8] = trace.hitNormal.z;

    values[9]  = trace.hitTangent.x;
    values[10] = trace.hitTangent.y;
    values[11] = trace.hitTangent.z;

    values[12] = trace.hitUV.x;
    values[13] = trace.hitUV.y;

    values[14] = 1;
   
    values[15] = (float)trace.triIDs.x;
    values[16] = (float)trace.triIDs.y;
    values[17] = (float)trace.triIDs.z;
   
    values[18] = trace.bary.x;
    values[19] = trace.bary.y;
    values[20] = trace.bary.z;

    values[21] = id;
    values[22] = 0;
    values[23] = 0;

    //print( particles.structSize);
  //  print("hmmmmm");
    particles._buffer.SetData( values , 0 , id * particles.structSize , 24 );

  }

  public override void Activate(){
//    print("loading");
   // Saveable.Load(particles,"DNA/"+fileName); 
  }

  public override void Deactivate(){
  }

}



