using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class LifeForm : Cycle {

 // public bool active;

  public bool auto;
  
[ HideInInspector ] public List<Life> Lifes;
[ HideInInspector ] public List<Form> Forms;


public void OnRenderObject(){
  if( auto ){
    if( created ){ _WhileDebug(); }
  }
}

public void LateUpdate(){
  if( auto ){
    if( birthing ){ _WhileBirthing(1);}
    if( living ){ _WhileLiving(1); }
    if( dying ){ _WhileDying(1); }
  }
}


public void OnEnable(){
  if( auto ){
    _Create(); 
    _OnGestate();
    _OnGestated();
    _OnBirth(); 
    _OnBirthed();
    _OnLive(); 
  }
}

public void OnDisable(){

  if( auto ){
    _Destroy();
  } 
   
}




}
