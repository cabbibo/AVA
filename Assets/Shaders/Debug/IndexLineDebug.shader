﻿Shader "Debug/IndexLine" {
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

      #pragma multi_compile __ Enable9Struct
      #pragma multi_compile __ Enable12Struct
      #pragma multi_compile __ Enable16Struct
		  #pragma multi_compile __ Enable24Struct
		  #pragma multi_compile __ Enable36Struct

		  #pragma target 4.5

		  #pragma vertex vert
		  #pragma fragment frag

		  #include "UnityCG.cginc"


      
		  #include "../Chunks/StructIfDefs.cginc"


		  uniform int _Count;
		  uniform float3 _Color;





      StructuredBuffer<Vert> _vertBuffer;
      StructuredBuffer<int> _triBuffer;

      //A simple input struct for our pixel shader step containing a position.
      struct varyings {
          float4 pos : SV_POSITION;
      };

      //Our vertex function simply fetches a point from the buffer corresponding to the vertex index
      //which we transform with the view-projection matrix before passing to the pixel program.
      varyings vert (uint id : SV_VertexID){

        varyings o;

        // Getting ID information
        int baseTri = id / 6;
        int triID = id % 6;
        int whichTri = triID/2;
        int alternate = id %2;

        // Making sure we aren't looking up into a bad areas
        if( baseTri*3+whichTri < _Count ){

        	int t1 = _triBuffer[baseTri*3+ ((whichTri+0)%3)];
        	int t2 = _triBuffer[baseTri*3+ ((whichTri+1)%3)];


        	Vert v1 = _vertBuffer[t1];
        	Vert v2 = _vertBuffer[t2];

      		float3 pos;;
      		if( alternate == 0 ){
      			pos = v1.pos;
      		}else{
      			pos = v2.pos;
      		}

	        o.pos = mul (UNITY_MATRIX_VP, float4(pos,1.0f));
	    
       	}

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
