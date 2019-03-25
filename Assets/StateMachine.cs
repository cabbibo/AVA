using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class StateMachine : Cycle
{
  

  public State[] states;
  public int activeState;
  public TitleMaker titleMaker;
  public TitleMaker avatarNameMaker;
  public Glitch glitch;


  public GameObject mapPrefab;

  public AudioSource aud;

  public ScreenData screenData;

  public TextMesh title;
  public TextMesh stateTitle;
  public TextMesh info;
  public TextMesh map;

  public GameObject[] maps;
  public GameObject upperData;
  public GameObject subStateData;
  public GameObject pushButton1;
  public GameObject avatarName;

  public bool downUp;
  public bool horizontal;
  public float swipeVal;

  public void SetTitle(string info){
    title.text = "DATA  : " + info;
  }

  public void SetAvatar( string info ){
    avatarName.GetComponent<TextMesh>().text = info;
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
    avatarNameMaker.StartMaking();
    
    SetMap();
  
  }

  
  public override void Create(){
    
    screenData.SetFrame();


    upperData.transform.position = screenData.topLeft;
    subStateData.transform.position = screenData.bottomLeft + screenData.up *(states.Length+1) * .2f;
    avatarName.transform.position = screenData.bottomLeft + screenData.up *(states.Length+3) * .2f;

    
    pushButton1.transform.position = screenData.bottomRight;
    pushButton1.transform.position += screenData.up * pushButton1.transform.localScale.y * .5f;
    pushButton1.transform.position += -screenData.right * pushButton1.transform.localScale.x  * .5f;
    

    avatarNameMaker = avatarName.GetComponent<TitleMaker>();

    maps = new GameObject[states.Length];
    for( int i = 0; i < states.Length; i++ ){
      
      maps[i] = Instantiate(mapPrefab);
      maps[i].transform.position =  screenData.bottomLeft; //title.gameObject.transform.position;

      maps[i].transform.position += screenData.up  * .2f * i;
      maps[i].GetComponent<Renderer>().enabled = true;
    
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
