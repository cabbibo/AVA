using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Interface : MonoBehaviour {

 // public List<FaceButton> buttons;

  public float buttonSize;
  public float padding;

  public float distance;
  public float border;
  public Transform viewpoint;
  public Transform quad;

  private float _ratio;

    public LineRenderer borderLine;

  public Vector3 bottomLeft;
  public Vector3 bottomRight;
  public Vector3 topLeft;
  public Vector3 topRight;
  public float width;
  public float height;
  public Vector3 normal;
  public Vector3 up;
  public Vector3 right;

  public Vector3 centerPosition;
  // Use this for initialization
  void Start () {
    borderLine = GetComponent<LineRenderer>();
  }
   // Update is called once per frame
  void LateUpdate () {

    SetFrame();
  }

  void SetFrame(){

    _ratio = (float)Screen.width / (float)Screen.height;

    Camera cam = Camera.main;

    Vector3  tmpP = cam.transform.position;
    Quaternion tmpR = cam.transform.rotation;

    cam.transform.position = viewpoint.position;//transform;
    cam.transform.rotation = viewpoint.rotation;//transform;

    bottomLeft = Camera.main.ViewportToWorldPoint(new Vector3( border ,_ratio *border,distance));  
    bottomRight = Camera.main.ViewportToWorldPoint(new Vector3(1- border,_ratio *border,distance));
    topLeft = Camera.main.ViewportToWorldPoint(new Vector3(border,1-_ratio * border,distance));
    topRight = Camera.main.ViewportToWorldPoint(new Vector3(1-border,1-_ratio * border,distance));


    normal = transform.forward;


    up = -(bottomLeft - topLeft).normalized;
    right = -(bottomLeft - bottomRight).normalized;


    transform.localScale = new Vector3( (bottomLeft - bottomRight).magnitude , (bottomLeft - topLeft).magnitude , .1f );

    width = (bottomLeft - bottomRight).magnitude;
    height = (bottomLeft - topLeft).magnitude;
    

    cam.transform.position = tmpP;
    cam.transform.rotation = tmpR;



    centerPosition = bottomLeft-(bottomLeft - bottomRight)* .5f+ up * .02f;

    borderLine.SetPosition( 0 , bottomLeft );
    borderLine.SetPosition( 1 , bottomRight );
    borderLine.SetPosition( 2 , topRight );
    borderLine.SetPosition( 3 , topLeft );
    borderLine.SetPosition( 4 , bottomLeft );

    transform.localPosition = new Vector3( 0, 0, distance);
    transform.localRotation = Quaternion.identity;




  }






}