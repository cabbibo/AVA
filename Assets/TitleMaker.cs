using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TitleMaker : MonoBehaviour
{
  public Renderer rend;
  public TextMesh mesh;
  public float currentLetter;

  public bool making;
  public float speed;
  public float lastLetterTime;

  public AudioSource aud;
  public TitleMaker next;

  public string[] stringArray;

  int totalCount;
  public void StartMaking(){
    print("splitting");
    print( mesh.text.Length);
    stringArray = mesh.text.Split(" "[0]);
    print( stringArray.Length );
    lastLetterTime = Time.time + speed * 4;

    totalCount= 0;
    for( int i = 0; i < stringArray.Length; i++ ){
      totalCount += stringArray[i].Length;
    }
    print( totalCount );
    
    Reset();
    making = true;
  }

  public void Reset(){
    currentLetter = 0;
    if( next != null ){ next.Reset(); }
  }

  public void NewLetter(){
    currentLetter ++;
    lastLetterTime = Time.time;
    aud.pitch = Random.Range( .6f , 1.4f );
    aud.Play();
    if( currentLetter == totalCount ){
      print("donzo");
      making = false;
      if( next != null ){ next.StartMaking(); }
    }
  }


  public void Update(){

    if( making == true ){

      if( Time.time - lastLetterTime > speed ){
        NewLetter();
      }

     
    }

     rend.material.SetFloat("_CurrentLetter", currentLetter);

  }



}
