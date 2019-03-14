using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BrushHolder : State
{

  public int activeBrush;
  public Animations animations;

  public StateMachine stateMachine;

  public SkinnedMeshRenderer AVA;
  public Mesh bakedMesh;
  public MeshCollider collision;
  public MeshRenderer fakeRepresent;
  public MeshFilter fakeFilter;

  public PlaceParticlesOnMesh[] brushes;

  public override void Create(){

    for( int i = 0; i < brushes.Length; i++ ){
      Cycles.Add(brushes[i]);
    }


  }

  public override void OnLive(){
    AVA.BakeMesh( bakedMesh );
    fakeFilter.mesh = bakedMesh;
    collision.sharedMesh = bakedMesh;
  }



  public override void WhileLiving(float v){
    numberStates = brushes.Length;
    currentState = activeBrush;
  }

  public override void horizontalSwipe( float val ){

    if( val < 0 ){
      brushes[activeBrush].drawable = false;
      activeBrush ++;
      activeBrush %= brushes.Length;
      brushes[activeBrush].drawable = true;
    }else{
      brushes[activeBrush].drawable = false;
      activeBrush --;
      if( activeBrush < 0 ){ activeBrush += brushes.Length; }
      brushes[activeBrush].drawable = true;
    }

    
    stateMachine.SetInfo(activeBrush,brushes.Length);
      stateMachine.SetTitle(brushes[activeBrush].gameObject.name);

  }



  public override void Activate(){
    brushes[activeBrush].drawable = true;
    animations.animator.Play("T-Pose");    
    stateMachine.SetInfo(activeBrush,brushes.Length);
      stateMachine.SetTitle(brushes[activeBrush].gameObject.name);

  }


  public override void Deactivate(){
    brushes[activeBrush].drawable = false;
    animations.animator.Play(animations.animations[animations.activeAnimation]);
  }

}
