using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class StateMachine : Cycle
{
  

  public State[] states;
  public int activeState;



  public TextMesh title;

  public void SetInfo(string info){
    title.text = info;
  }
  public override void Create(){
    for( int i = 0; i < states.Length; i++ ){
      Cycles.Add(states[i]);
    }
  }
  public override void OnLive(){
    print("hi");
    states[activeState]._Activate();
  }

  public void verticalSwipe( float val ){

    if( val > 0 ){
      states[activeState].Deactivate();
      activeState ++;
      activeState %= states.Length;
      states[activeState]._Activate();
    }else{
      states[activeState].Deactivate();
      activeState --;
      if( activeState < 0 ){ activeState += states.Length;}
      states[activeState]._Activate();
    }

  }

  public void horizontalSwipe( float val ){
    states[activeState].horizontalSwipe( val );
  }


}
