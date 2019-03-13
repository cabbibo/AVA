using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ParticlesOnParticleSim : LifeForm
{

  public ParticlesOnParticle particles;
  public Life sim;

  public override void Create(){
    Cycles.Insert(0,particles);
    Cycles.Insert(0,sim);
  }

  public override void Bind(){

    sim.BindPrimaryForm( "_VertBuffer", particles );
    sim.BindForm( "_BaseBuffer", particles.baseForm );
  
    sim.BindAttribute( "_ParticlesPerParticle" , "particlesPerParticle" , particles );
  
  }

  



}
