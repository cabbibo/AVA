using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Effector : Form {

  public Form baseForm;

	public override void SetStructSize(){ structSize = 16; }

  public override void SetCount(){ count = baseForm.count; }

}
