using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Info : State
{

  public int activeInfo;
  public TextMesh infoMesh;

  public StateMachine stateMachine;
  
  public Inform[] infos;
  public TitleMaker infoMaker;

  

  public override void Create(){


  }


  public override void WhileLiving(float v){
    numberStates = infos.Length;
    currentState = activeInfo;
  }

  public override void horizontalSwipe( float val ){

    if( val < 0 ){
      activeInfo ++;
      activeInfo %= infos.Length;
    }else{
      activeInfo --;
      if( activeInfo < 0 ){ activeInfo += infos.Length; }
    }
   // rotator.eulerAngles = new Vector3(0, infos[activeInfo] / (2* Mathf.PI) * 360 + 180, 0);
    infoMesh.text = infos[activeInfo].info;
    stateMachine.SetTitle(infos[activeInfo].title);
    stateMachine.SetInfo(activeInfo,infos.Length);
    infoMaker.StartMaking();
  
  }



  public override void Activate(){
    //infos[activeBrush].drawable = true;
    infoMesh.text = infos[activeInfo].info;
    infoMesh.gameObject.GetComponent<Renderer>().enabled = true;

    stateMachine.SetTitle(infos[activeInfo].title);
    stateMachine.SetInfo(activeInfo,infos.Length);
    infoMaker.StartMaking();
    
  }


  public override void Deactivate(){

    infoMesh.gameObject.GetComponent<Renderer>().enabled = false;
   // infos[activeBrush].drawable = false;
  }

}