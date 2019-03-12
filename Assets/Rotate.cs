using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotate : MonoBehaviour
{

  public float speed;
  public int targetFrameRate;
  
    // Start is called before the first frame update
    void Start()
    {

        // Make the game run as fast as possible
        Application.targetFrameRate = targetFrameRate;

    }

    // Update is called once per frame
    void Update()
    {
        transform.Rotate( Vector3.up , speed * Time.deltaTime );
    }
}
