using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotate : MonoBehaviour
{

  public float speed;
  public int targetFrameRate;

  public float rotationVel;
  public float rotationVal;


  public void WhileDown(Vector2 vel ){
    print("hmmmm");
    rotationVel += vel.x;
  }
  
    // Start is called before the first frame update
    void Start()
    {

        // Make the game run as fast as possible
        Application.targetFrameRate = targetFrameRate;

    }

    // Update is called once per frame
    void Update()
    {

        rotationVal += rotationVel;
        rotationVel *= .9f;
        transform.eulerAngles = new Vector3( 0 , -rotationVal * .01f , 0 );//( Vector3.up , speed * Time.deltaTime );
    }
}
