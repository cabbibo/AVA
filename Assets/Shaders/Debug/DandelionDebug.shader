Shader "Debug/DandelionDebug" {
	Properties {

    _Color ("Color", Color) = (1,1,1,1)
    [Toggle(Enable9Struct)]  _Struct9("9 Struct", Float) = 0
    [Toggle(Enable12Struct)] _Struct12("12 Struct", Float) = 0
    [Toggle(Enable16Struct)] _Struct16("16 Struct", Float) = 0
    [Toggle(Enable24Struct)] _Struct24("24 Struct", Float) = 0
    [Toggle(Enable36Struct)] _Struct36("36 Struct", Float) = 0
	}


  SubShader{
//        Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
    Cull Off
    Pass{

      //Blend SrcAlpha OneMinusSrcAlpha // Alpha blending

      CGPROGRAM
      #pragma target 4.5

      #pragma vertex vert
      #pragma fragment frag

      #include "UnityCG.cginc"
      #include "../Chunks/StructIfDefs.cginc"

		  uniform int _Count;
      uniform float3 _Color;


      StructuredBuffer<Vert> _VertBuffer;
      StructuredBuffer<Vert> _SkeletonBuffer;


      //uniform float4x4 worldMat;

      //A simple input struct for our pixel shader step containing a position.
      struct varyings {
          float4 pos      : SV_POSITION;
          float debug     : TEXCOORD0;
      };


      int _VertsPerVert;
      int _NumVertsPerHair;

      //Our vertex function simply fetches a point from the buffer corresponding to the vertex index
      //which we transform with the view-projection matrix before passing to the pixel program.
      varyings vert (uint id : SV_VertexID){

        varyings o;

        int base = id / 2;
        int alternate = id %2;
       	int sID = ((base / _VertsPerVert)+1) * _NumVertsPerHair -1;
        if( base < _Count ){

        	Vert v1 = _VertBuffer[base];
        	Vert v2 = _SkeletonBuffer[sID];

        	

        		float3 pos; 
        		if( alternate == 0 ){
        			pos = v1.pos;
        		}else{
        			pos = v2.pos;
        		}
	       
	        o.pos = mul (UNITY_MATRIX_VP, float4(pos,1.0f));
	        o.debug = 0;

					if( v2.uv.x > 0 && v1.uv.x > 0 ){
						o.debug = 1;
					}

       	}
        return o;
      }




      //Pixel function returns a solid color for each point.
      float4 frag (varyings v) : COLOR {

      		if( v.debug == 0 ){ discard;}
          return float4( _Color , 1 );

      }

      ENDCG

    }
  }

  Fallback Off


}
