﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Themes : State
{

  public int activeTheme;

  public Theme[] themes;

  public Body body;
  public MeshRenderer background;
  public MeshRenderer platform;

  public override void Create(){


  }

  public override void horizontalSwipe( float val ){

    if( val < 0 ){
     activeTheme ++;
     activeTheme %= themes.Length; 
   }else{
     activeTheme --;
     if(activeTheme < 0 ){activeTheme += themes.Length; }
     
   }

   SetActiveTheme();


  }


  void SetActiveTheme(){
    body.render.material = themes[activeTheme].bodyMat;
    background.material = themes[activeTheme].skyboxMat;
    platform.material = themes[activeTheme].platformMat;
  }


  public override void Activate(){

    print("HELLO");
    SetActiveTheme();
    
  }


  public override void Deactivate(){

  }

}