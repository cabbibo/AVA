using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ParticlesOnLifeForm: LifeForm {
  


  public Vector3 cameraUp;
  public Vector3 cameraLeft;
  public float radius;

  public Life place;

  public SkinnedLifeForm skin;

  public Form verts;

  public ParticleTransferVerts bodyVerts;
  public ParticleTransferTris bodyTris;
  public Life bodyTransfer;
  public Body body;

  public float whirlwindSpeed;
  public int whirlwindState;

  // Use this for initialization
  public override void Create(){
    Lifes.Add(place);
    Lifes.Add(bodyTransfer);
    Forms.Add(skin.verts);
    Forms.Add(verts);
    Forms.Add(bodyVerts);
    Forms.Add(bodyTris);



    
    verts._Create();
    
    bodyVerts._Create();
    bodyTris._Create();
    body._Create();



  place._Create();
  bodyTransfer._Create();

    place.BindPrimaryForm("_VertBuffer",verts);
    place.BindForm("_SkinnedBuffer",skin.verts);
    place.BindAttribute("_Whirlwind", "whirlwindState" , this);
    place.BindAttribute("_WhirlwindSpeed", "whirlwindSpeed" , this);

    bodyTransfer.BindAttribute("_CameraUp"  , "cameraUp" , this );
    bodyTransfer.BindAttribute("_CameraLeft"  , "cameraLeft" , this );
    bodyTransfer.BindAttribute("_Radius" , "radius" , this );


    bodyTransfer.BindPrimaryForm("_VertBuffer", bodyVerts);
    bodyTransfer.BindForm("_ParticleBuffer", verts); 


 

  }


  public override void OnGestate(){
    verts._OnGestate();
    bodyTris._OnGestate();
    bodyVerts._OnGestate();
    body._OnGestate();

  }
  public override void OnBirth(){
    body.Show();
  }

  public override void WhileLiving(float v){


//    print(Camera.main);
    cameraLeft = -Camera.main.transform.right;
    cameraUp = Camera.main.transform.up;

    place.Live();
    bodyTransfer.Live();
    body.WhileLiving(1);
  }

}
