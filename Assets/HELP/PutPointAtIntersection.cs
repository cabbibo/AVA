using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PutPointAtIntersection : MonoBehaviour {

  public Transform point;

  public CalcLife life;
	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		point.position = new Vector3( life.value.x , life.value.y , life.value.z );
	}
}
