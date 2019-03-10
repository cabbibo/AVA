using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SkinnedLifeForm : MeshLifeForm {
  
  public Life skin;

  public Form bones;

	// Use this for initialization
	public override void Create(){
    Lifes.Add(skin);
    Forms.Add(verts);
    Forms.Add(triangles);
    Forms.Add(bones);

    skin._Create();

    verts._Create();
    triangles._Create();
    bones._Create();

    skin.BindPrimaryForm("_VertBuffer",verts);
    skin.BindForm("_BoneBuffer",bones);

	}


  public override void OnGestate(){

    verts._OnGestate();
    triangles._OnGestate();
    bones._OnGestate();
  }

  public override void WhileLiving(float v){
    skin.Live();
    ((Bones)bones).UpdateBones();
  }

}
