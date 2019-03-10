Shader "Debug/Body" {
	Properties {
  	_Color ("Color", Color) = (1,1,1,1)
    [Toggle(Enable9Struct)] _Struct9("9 Struct", Float) = 0
    [Toggle(Enable12Struct)] _Struct12("12 Struct", Float) = 0
  	[Toggle(Enable16Struct)] _Struct16("16 Struct", Float) = 0
  	[Toggle(Enable24Struct)] _Struct24("24 Struct", Float) = 0
  	[Toggle(Enable36Struct)] _Struct36("36 Struct", Float) = 0
	}


  SubShader{

    Pass{

		  CGPROGRAM

		  #pragma target 4.5

		  #pragma vertex vert
		  #pragma fragment frag

		  #include "UnityCG.cginc"


      
		  #include "../Chunks/StructIfDefs.cginc"


		  uniform int _Count;
		  uniform float3 _Color;

      StructuredBuffer<Vert> _VertBuffer;
      StructuredBuffer<int> _TriBuffer;

      //A simple input struct for our pixel shader step containing a position.
      struct varyings {
          float4 pos : SV_POSITION;
      };

      //Our vertex function simply fetches a point from the buffer corresponding to the vertex index
      //which we transform with the view-projection matrix before passing to the pixel program.
      varyings vert (uint id : SV_VertexID){

        varyings o;

        Vert v = _VertBuffer[_TriBuffer[id]];
	      o.pos = mul (UNITY_MATRIX_VP, float4(v.pos,1.0f));
	    
        return o;

      }

      //Pixel function returns a solid color for each point.
      float4 frag (varyings v) : COLOR {
          return float4( _Color , 1 );
      }

      ENDCG

    }
  }

  Fallback Off


}
