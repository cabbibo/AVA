using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;


[CustomEditor(typeof(PlaceParticlesOnMesh))]
public class PlaceParticlesOnMeshInspector : Editor {
 
  private PlaceParticlesOnMesh creator;

  private void OnEnable () {
    creator = target as PlaceParticlesOnMesh ;
  }


  public override void OnInspectorGUI () {

    DrawDefaultInspector();
    
    if(GUILayout.Button("SAVE"))
    {
      Saveable.Save(creator.particles,"DNA/"+creator.fileName);
    } 

    if(GUILayout.Button("LOAD"))
    {
      Saveable.Load(creator.particles,"DNA/"+creator.fileName);
    }
  }
}
