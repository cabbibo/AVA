using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class StateMachine : Cycle
{
  

  public State[] states;
  public int activeState;
  public TitleMaker titleMaker;
  public Glitch glitch;


  public GameObject mapPrefab;

  public AudioSource aud;

  public TextMesh title;
  public TextMesh stateTitle;
  public TextMesh info;
  public TextMesh map;

  public GameObject[] maps;

  public bool downUp;
  public bool horizontal;
  public float swipeVal;

  public void SetTitle(string info){
    title.text = "DATA  : " + info;
  }

  public void SetInfo(int number , int total){
    string id = "";
    for(int i = 0; i < total; i++ ){
      if( i == number){ id += "X";}else{ id += "-"; }
    }
    info.text = "ID    : " + id;
  }


  public void SetStateTitle( string info ){
    stateTitle.text = "STATE : " + info;
  }

  public void SetMap(){
    

    for( int i = 0; i <states.Length; i++){

      if( i == activeState ){
        maps[i].GetComponent<Renderer>().material.SetColor("_Color", Color.red);
      }else{
        maps[i].GetComponent<Renderer>().material.SetColor("_Color", Color.green);
      }
      states[i].WhileLiving(1);
      string fText="";
      fText += states[i].gameObject.name;
      for( int j = 0; j < 10-states[i].gameObject.name.Length ;j++){
        fText += " ";
      }
      fText += "| ";
      for( int j = 0; j < states[i].numberStates; j++){
        if( j == states[i].currentState ){ fText += "X"; }else{ fText += "-"; }
      }
      fText += " |\n";
      maps[i].GetComponent<TextMesh>().text = fText;
    }


  }



  public void TriggerGlitch(){
    glitch.glitchPow = 0;
    glitch.glitchStartTime = Time.time;
    glitch.enabled = true;
    glitch.upDown = horizontal ? 0 :1;
    glitch.swipeVal = swipeVal;
    float p = Random.Range( 0, .99f);
    glitch.glitchLength = .1f + p ;
    aud.pitch = .6f/ (.1f+p);//Random.Range(.6f,1.4f);
    aud.Play();
  }

  public override  void WhileLiving(float v){
    if( glitch.glitchPow > 1 ){

      if(glitch.enabled == true ){
        glitch.enabled = false;

        DoSwap();
      }
    }
  }


  public void DoSwap(){

    if( horizontal ){

      states[activeState].horizontalSwipe( swipeVal );
    
    }else{
    
      states[activeState].Deactivate();
    
      if( downUp ){
        activeState ++;
        activeState %= states.Length;
      }else{
        activeState --;
        if( activeState < 0 ){ activeState += states.Length;}
      }

      states[activeState].Activate();
      //SetStateTitle( states[activeState].gameObject.name );
    }

    titleMaker.StartMaking();
    
    SetMap();
  
  }

  
  public override void Create(){
    
    maps = new GameObject[states.Length];
    for( int i = 0; i < states.Length; i++ ){
      
      maps[i] = Instantiate(mapPrefab);
      maps[i].transform.position = title.gameObject.transform.position;

      maps[i].transform.position += Vector3.up * (-.2f * i + .8f);
      maps[i].GetComponent<Renderer>().enabled = true;
     // maps[i]

      Cycles.Add(states[i]);

    }

    titleMaker = maps[0].GetComponent<TitleMaker>();
    for( int i = 0; i < maps.Length-1; i++ ){
      maps[i].GetComponent<TitleMaker>().next = maps[i+1].GetComponent<TitleMaker>();
    }

    maps[maps.Length-1].GetComponent<TitleMaker>().next = title.gameObject.GetComponent<TitleMaker>();

  }
  public override void OnLive(){

    states[activeState]._Activate();
   // SetStateTitle( states[activeState].gameObject.name );
  }

  public void verticalSwipe( float val ){

    if( val > 0 ){
      downUp = true;
      swipeVal = val;
      horizontal = false;
      TriggerGlitch();
    }else{
      downUp = false;

      swipeVal = val;
      horizontal = false;
      TriggerGlitch();
    }

  }

  public void horizontalSwipe( float val ){
    horizontal = true;
    swipeVal = val;
    TriggerGlitch();
  }


}
