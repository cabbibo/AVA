
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;





public class TubeHair : LifeForm {

  public Life SetHairPosition;
  public Life HairCollision;
  
  public ConstraintLife HairConstraint0;
  public ConstraintLife HairConstraint1;


  public Form Base;
  public Hair Hair;

  public bool reduce;
  public Life reduceLife;

  public float tubeRadius;


  public Life HairTransfer;

  public TubeTriangles TubeTriangles;
  public TubeVerts TubeVerts;

  public Body body;

  public float[] transformArray;

  public override void Create(){

    transformArray = new float[16];

    
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

    Base._Create();
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


  }

  public override void OnGestate(){

    Base._OnGestate();
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

    transformArray = HELP.GetMatrixFloats( ((ParticlesOnMesh)Base).mesh.gameObject.transform.localToWorldMatrix );
    HairCollision.shader.SetFloat("_HairLength", Hair.length ); 
    HairCollision.shader.SetInt("_NumVertsPerHair", Hair.numVertsPerHair); 
    HairCollision.Live();
    HairConstraint0.Live();
    HairConstraint1.Live();
    HairTransfer.Live();

    body.WhileLiving(1);


  }

  public override void WhileDebug(){
    Base.WhileDebug();
  }

}