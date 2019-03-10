using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Hands : MonoBehaviour {

  public Transform hl;
  public Transform hr;

  public Vector3 handL;
  public Vector3 handR;

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {

    handL = hl.position;
    handR = hr.position;
		
	}
}
