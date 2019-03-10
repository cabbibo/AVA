using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlaceParticlesOnMesh : LifeForm {


  public bool drawable;
  public bool dragDraw;


  public PlacedDynamicMeshParticles particles;
  public Life place;
  public CalcLife intersect;


  public string fileName;
  public Vector3 cameraUp;
  public Vector3 cameraLeft;
  public float radius;
  public float[] transformFloats;

  public int test;

  public TouchToRay touch;

  public Body skin;
  public Mesh mesh;

  public Saveable saver;


  // Use this for initialization
  public override void _Create(){

    touch = Camera.main.GetComponent<TouchToRay>();

    Cycles.Insert(0,place);

    Cycles.Insert(0,intersect);
    
    Cycles.Insert(0,particles);

    //print("insetring");
    
    if( mesh == null ){ mesh = skin.gameObject.GetComponent<MeshFilter>().mesh; }
  
    DoCreate();

  }

  public override void Bind(){

    place.BindPrimaryForm("_VertBuffer",particles);
    place.BindForm("_SkinnedBuffer",skin.verts);
    place.BindAttribute("_Transform" , "transformFloats" , this );

    intersect.BindForm("_ParticleBuffer",particles);
    intersect.BindForm("_SkinnedVertBuffer",skin.verts);
    intersect.BindPrimaryForm("_SkinnedTriBuffer",skin.triangles);
    intersect.BindAttribute("_RO"  , "RayOrigin" , touch );
    intersect.BindAttribute("_RD"  , "RayDirection" , touch );
    
    intersect.BindAttribute("_Transform" , "transformFloats" , this ); 

  }


  public override void OnGestated(){
    print( particles._buffer);
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
        //intersect.active = true;
        intersect.readBack = true;
        if( touch.JustDown == 1  ){
          intersect.active = true;
        }else{
          intersect.active = false;
        }

        if( dragDraw ){
          if( touch.Down == 1 ){
            intersect.active = true;
          }else if( touch.Down == 0){
            intersect.active = false;
          }
        }

      }else{
        intersect.active = false;
        intersect.readBack = false;
      }
    
    }

  }

  public override void Activate(){
    print("loading");
    Saveable.Load(particles,"DNA/"+fileName); 
  }

  public override void Deactivate(){
  }

}



