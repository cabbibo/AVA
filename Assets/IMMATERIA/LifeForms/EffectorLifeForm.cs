using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EffectorLifeForm : LifeForm {

  public Life transfer;
  public Life[] passes;
  public Body body;
  public bool showBody;

  public Effector skeleton;
  public Form baseVerts;

  public Form ogVerts;
  public MeshVerts verts;
  public MeshTris tris;


  // Use this for initialization
  public override void Create(){

    Cycles.Insert(0,transfer);
    
    for( int i = 0; i < passes.Length; i++ ){
      Cycles.Insert(i+1,passes[i]);
    }


    Cycles.Insert(passes.Length + 1 , skeleton);
    Cycles.Insert(passes.Length + 2 , body );

  }

  public override void Bind(){
    
    for( int i = 0; i < passes.Length; i++ ){
      passes[i].BindPrimaryForm("_SkeletonBuffer", skeleton);
      passes[i].BindForm("_BaseBuffer", baseVerts); 
    }

    transfer.BindPrimaryForm("_VertBuffer", verts);
    transfer.BindForm("_SkeletonBuffer", skeleton); 
    transfer.BindForm("_OGBuffer", ogVerts ); 

  }



  
  public override void OnBirth(){
   // body.Show();
  }

  public override void WhileLiving(float v){

    if( active == true ){

      if( showBody == true ){
        body.active = true;
      }else{
        body.active = false;
      }

    }
  }

  public override void Activate(){
    body.Show();
  }

  public override void Deactivate(){
    body.Hide();
  }

}
