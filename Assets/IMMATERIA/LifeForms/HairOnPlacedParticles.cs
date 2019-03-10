
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;


public class HairOnPlacedParticles : LifeForm {


  public float noiseSize;
  public float noiseSpeed;
  public float noiseForce;
  public float normalForce;
  public float dampening;
  public float upForce;

  public Life SetHairPosition;
  public Life HairCollision;
  
  public ConstraintLife HairConstraint0;
  public ConstraintLife HairConstraint1;

  public PlacedDynamicMeshParticles Base;
  public Hair Hair;

  public float tubeRadius;
 
  public Life HairTransfer;

  public TubeTriangles TubeTriangles;
  public TubeVerts TubeVerts;

  public Body body;
  public bool showBody = true;

  public float[] transformArray;

  public override void Create(){


    
    /*  
      All of this info should be visualizable!
    */

    Lifes.Add( SetHairPosition );
    Lifes.Add( HairCollision );
    Lifes.Add( HairConstraint0 );
    Lifes.Add( HairConstraint1 );
    Lifes.Add( HairTransfer);

    Forms.Add( Base );
    Forms.Add( Hair );
    Forms.Add( TubeVerts );
    Forms.Add( TubeTriangles );


    SetHairPosition._Create();
    HairCollision._Create();
    HairConstraint0._Create();
    HairConstraint1._Create();

    Hair._Create();


    HairTransfer._Create();
    TubeVerts._Create();
    TubeTriangles._Create();


    SetHairPosition.BindPrimaryForm("_VertBuffer", Hair);
    SetHairPosition.BindForm("_BaseBuffer", Base );

    HairCollision.BindPrimaryForm("_VertBuffer", Hair);
    HairCollision.BindForm("_BaseBuffer", Base ); 

    HairConstraint0.BindInt("_Pass" , 0 );
    HairConstraint0.BindPrimaryForm("_VertBuffer", Hair);

    HairConstraint1.BindInt("_Pass" , 1 );
    HairConstraint1.BindPrimaryForm("_VertBuffer", Hair);

    HairTransfer.BindPrimaryForm("_VertBuffer", TubeVerts );
    HairTransfer.BindForm("_HairBuffer", Hair);

    HairTransfer.BindAttribute( "_TubeWidth" , "width" , TubeVerts );
    HairTransfer.BindAttribute( "_TubeLength" , "length" , TubeVerts );
    HairTransfer.BindAttribute( "_NumVertsPerHair" , "numVertsPerHair", Hair );
    HairTransfer.BindAttribute( "_TubeRadius"  , "tubeRadius", this );

    SetHairPosition.BindAttribute( "_HairLength"  , "length", Hair );
    SetHairPosition.BindAttribute( "_NumVertsPerHair" , "numVertsPerHair", Hair );

    // Don't need to bind for all of them ( constraints ) because same shader
    HairCollision.BindAttribute( "_HairLength"  , "length", Hair );
    HairCollision.BindAttribute( "_NumVertsPerHair" , "numVertsPerHair", Hair );
    HairCollision.BindAttribute( "transform" , "transformArray" , this );
    HairCollision.BindAttribute( "_NoiseSpeed" , "noiseSpeed" , this );
    HairCollision.BindAttribute( "_NoiseForce" , "noiseForce" , this );
    HairCollision.BindAttribute( "_NoiseSize" , "noiseSize" , this );
    HairCollision.BindAttribute( "_NormalForce" , "normalForce" , this );
    HairCollision.BindAttribute( "_Dampening" , "dampening" , this );
    HairCollision.BindAttribute( "_UpForce" , "upForce" , this );



  }

  public override void OnGestate(){

    Hair._OnGestate();

    TubeTriangles._OnGestate();
    TubeVerts._OnGestate();

    body._OnGestate();

  }


  public override void OnBirth(){
    SetHairPosition.Live();
    body.Show();
  }

  public override void WhileLiving(float v){

    transformArray = HELP.GetMatrixFloats( this.transform.localToWorldMatrix );
    //HairCollision.shader.SetFloat("_HairLength", Hair.length ); 
    //HairCollision.shader.SetInt("_NumVertsPerHair", Hair.numVertsPerHair); 
    HairCollision.Live();
    HairConstraint0.Live();
    HairConstraint1.Live();

    if( showBody == true ){
    HairTransfer.Live();

    body.WhileLiving(1);
    }else{
      body.Hide();
    }


  }

  public override void WhileDebug(){
    Base.WhileDebug();
  }


  public override void Activate(){
    body.Show();
  }

  public override void Deactivate(){
    body.Hide();
  }


}