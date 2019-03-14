using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotations : State
{

  public int activeRotation;
  public Transform rotator;

  public StateMachine stateMachine;
  
  public float[] rotations;

  

  public override void Create(){


  }


  public override void WhileLiving(float v){
    numberStates = rotations.Length;
    currentState = activeRotation;
  }

  public override void horizontalSwipe( float val ){

    if( val < 0 ){
      activeRotation ++;
      activeRotation %= rotations.Length;
    }else{
      activeRotation --;
      if( activeRotation < 0 ){ activeRotation += rotations.Length; }
    }
    rotator.eulerAngles = new Vector3(0, rotations[activeRotation] / (2* Mathf.PI) * 360 + 180, 0);

    stateMachine.SetTitle(rotations[activeRotation].ToString());
    stateMachine.SetInfo(activeRotation,rotations.Length);
  
  }



  public override void Activate(){
    //rotations[activeBrush].drawable = true;

rotator.eulerAngles = new Vector3(0, rotations[activeRotation] / (2* Mathf.PI) * 360 + 180, 0);


    stateMachine.SetTitle(rotations[activeRotation].ToString());
    stateMachine.SetInfo(activeRotation,rotations.Length);

    
  }


  public override void Deactivate(){
   // rotations[activeBrush].drawable = false;
  }

}