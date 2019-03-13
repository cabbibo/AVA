using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Tracer : MonoBehaviour
{

    public MeshCollider person;
    public MeshCollider pedestal;

    public GameObject traceRepresent;

    public Vector3 triIDs;
    public Vector3 bary;

    public Vector3 hitPoint;
    public Vector3 hitNormal;
    public Vector3 hitTangent;
    public Vector3 hitUV;

    public bool down;

    // Update is called once per frame
    public void WhileDown( Ray ray) {
      

      RaycastHit hit;

      if (person.Raycast(ray, out hit, 100.0f))
      {
          down = true;

          hitPoint = hit.point;
          hitUV = hit.textureCoord;
          hitNormal = hit.normal;
          traceRepresent.transform.position = hitPoint;

          triIDs = new Vector3( 
          person.sharedMesh.triangles[ hit.triangleIndex * 3 + 0 ],
          person.sharedMesh.triangles[ hit.triangleIndex * 3 + 1 ],
          person.sharedMesh.triangles[ hit.triangleIndex * 3 + 2 ]);


          bary = hit.barycentricCoordinate;

          hitTangent  = bary.x * HELP.ToV3( person.sharedMesh.tangents[(int)triIDs.x] );
          hitTangent += bary.y * HELP.ToV3( person.sharedMesh.tangents[(int)triIDs.y] );
          hitTangent += bary.z * HELP.ToV3( person.sharedMesh.tangents[(int)triIDs.z] );
      
      }else{

        down = false;
        
      }


    }
}
