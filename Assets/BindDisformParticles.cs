using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BindDisformParticles : Cycle{


  public Life toBind;
  public Form disformParticles;
  public Body body;

  public override void Bind(){

    toBind.BindForm( "_DisformParticles" ,  disformParticles );

  }

  public override void WhileLiving( float v ){
    body.render.material.SetBuffer("_DisformParticles" , disformParticles._buffer);
    body.render.material.SetInt("_DisformParticles_COUNT", disformParticles.count );
  }

}
