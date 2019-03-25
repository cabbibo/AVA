using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScreenData : Cycle {

  public float distance;
  public float border;

  public float ratio;

  public Vector3 bottomLeft;
  public Vector3 bottomRight;
  public Vector3 topLeft;
  public Vector3 topRight;

  public float width;
  public float height;
  public Vector3 normal;
  public Vector3 up;
  public Vector3 right;

  public void SetFrame(){

    ratio = (float)Screen.width / (float)Screen.height;

    Camera cam = Camera.main;

    bottomLeft = Camera.main.ViewportToWorldPoint(new Vector3( border ,ratio *border,distance));  
    bottomRight = Camera.main.ViewportToWorldPoint(new Vector3(1- border,ratio *border,distance));
    topLeft = Camera.main.ViewportToWorldPoint(new Vector3(border,1-ratio * border,distance));
    topRight = Camera.main.ViewportToWorldPoint(new Vector3(1-border,1-ratio * border,distance));

    normal = transform.forward;

    up = -(bottomLeft - topLeft).normalized;
    right = -(bottomLeft - bottomRight).normalized;

    width = (bottomLeft - bottomRight).magnitude;
    height = (bottomLeft - topLeft).magnitude;
    
  }



}
