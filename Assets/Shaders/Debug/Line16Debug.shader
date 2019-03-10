Shader "Debug/16StructLine" {
	Properties {

    _Color ("Color", Color) = (1,1,1,1)
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
      #include "../Chunks/noise.cginc"
      #include "../Chunks/hsv.cginc"

		  uniform int _Count;
      uniform float3 _Color;

struct Vert{

  float3 pos;
  float3 oPos;
  float3 nor;
  float3 tan;
  float2 uv;
  float2 debug;
};



      StructuredBuffer<Vert> _vertBuffer;


      //uniform float4x4 worldMat;

      //A simple input struct for our pixel shader step containing a position.
      struct varyings {
          float4 pos      : SV_POSITION;
          float3 nor      : TEXCOORD0;
          float3 worldPos : TEXCOORD1;
          float3 eye      : TEXCOORD2;
          float debug    : TEXCOORD3;
          float2 uv       : TEXCOORD4;
      };


      //Our vertex function simply fetches a point from the buffer corresponding to the vertex index
      //which we transform with the view-projection matrix before passing to the pixel program.
      varyings vert (uint id : SV_VertexID){

        varyings o;

        int base = id / 2;
        int alternate = id %2;
        if( base + 1 < _Count ){


        	Vert v1 = _vertBuffer[base+0];
        	Vert v2 = _vertBuffer[base+1];

        	

        		float3 pos; float3 nor;
        		if( alternate == 0 ){
        			pos = v1.pos;
        			nor = pos - v1.oPos;
        		}else{
        			pos = v2.pos;
        			nor = pos - v2.oPos;
        		}

       		o.worldPos = (pos);///* .001/(.1+length(v.debug));//*(1/(.1+max(length(v.debug),0)));//mul( worldMat , float4( v.pos , 1.) ).xyz;
	        o.nor = nor;
	       
	        o.pos = mul (UNITY_MATRIX_VP, float4(o.worldPos,1.0f));
	        o.debug = 0;
					if( v2.uv.x > 0 ){
						o.debug = 1;
					}
       	}

        return o;

      }




      //Pixel function returns a solid color for each point.
      float4 frag (varyings v) : COLOR {
      		float3 col = float3(0,1,1);//v.debug;//normalize(v.nor) * .5 + .5;

      		if( v.debug == 0 ){ discard;}
         
          //col = float3( v.uv.x , v.uv.y , .5);
          return float4( _Color , 1 );
          //return float4( (normalize(v.nor)  * .5 + .5)*1000 * length(v.nor), 1 );

      }

      ENDCG

    }
  }

  Fallback Off


}
