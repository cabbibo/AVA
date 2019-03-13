using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ParticlesOnParticle : Particles
{

  public Form baseForm;
  public int particlesPerParticle;
  public override void SetCount(){ count = baseForm.count * particlesPerParticle; }

}
