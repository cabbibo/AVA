﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Animations : State
{

  public int activeAnimation;

  public Animator animator;
  public string[] animations;

  public GameObject AVA;


  public override void Create(){


  }

  public override void horizontalSwipe( float val ){

    if( val < 0 ){
      activeAnimation ++;
      activeAnimation %= animations.Length;
      animator.Play(animations[activeAnimation]);
    }else{
      activeAnimation --;
      if( activeAnimation < 0 ){ activeAnimation += animations.Length; }
      animator.Play(animations[activeAnimation]);
    }

  }



  public override void Activate(){
    //animations[activeBrush].drawable = true;

    
  }


  public override void Deactivate(){
   // animations[activeBrush].drawable = false;
  }

}