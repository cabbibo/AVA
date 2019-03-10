Shader "Debug/NormalLineDebug" {
	Properties {

    _Color ("Color", Color) = (1,1,1,1)
    _VecOrGrass("vecorGrass",float) = 0
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

            #pragma multi_compile __ Enable12Struct
      #pragma multi_compile __ Enable16Struct
      #pragma multi_compile __ Enable24Struct
      #pragma multi_compile __ Enable36Struct
      

      #include "../Chunks/StructIfDefs.cginc"

		  uniform int _Count;
      uniform float3 _Color;
      uniform float _VecOrGrass;


      StructuredBuffer<Vert> _VertBuffer;


      //uniform float4x4 worldMat;

      //A simple input struct for our pixel shader step containing a position.
      struct varyings {
          float4 pos      : SV_POSITION;
          float3 debug     : TEXCOORD0;
          float3 nor     : TEXCOORD1;
      };


      //Our vertex function simply fetches a point from the buffer corresponding to the vertex index
      //which we transform with the view-projection matrix before passing to the pixel program.
      varyings vert (uint id : SV_VertexID){

        varyings o;

        int base = id/2;
        int alternate = id %2;
        if( base < _Count ){


        	Vert v1 = _VertBuffer[base];

        	

    		float3 pos; 
    		if( alternate == 0 ){
    			pos = v1.pos;
    		}else{
          float3 dir = v1.tan * 3 + 3*v1.nor;
          o.debug = v1.tan * .5 + .5;
          if( _VecOrGrass > .5 ){
            dir =  float3(0,1,0) * 4 * v1.debug.x;
          o.debug = v1.debug.x;
          }
    			pos = v1.pos  + dir ;
    		  


        }
	       o.nor = normalize(v1.nor) * .5 + .5; 
	        o.pos = mul (UNITY_MATRIX_VP, float4(pos,1.0f));

       	}
        return o;
      }




      //Pixel function returns a solid color for each point.
      float4 frag (varyings v) : COLOR {

          return float4( v.debug , 1 );

      }

      ENDCG

    }
  }

  Fallback Off


}
