Shader "Debug/SDFBoneBuffer" {
    Properties {

    _Color ("Color", Color) = (1,1,1,1)
    _Size ("Size", float) = .01
  }


  SubShader{
    Cull Off
    Pass{

      CGPROGRAM
      


      #pragma target 4.5

      #pragma vertex vert
      #pragma fragment frag

      #include "UnityCG.cginc"



      /*      struct Vert{
          float3 pos;
          float3 nor;
          float3 tan;
          float2 uv;
          float debug;
        };*/


    struct Vert{
      float3 start;
      float3 end;
      float size;
      float debug;
    };


      uniform int _Count;
      uniform float3 _Color;

      StructuredBuffer<Vert> _VertBuffer;


      //uniform float4x4 worldMat;

      //A simple input struct for our pixel shader step containing a position.
      struct varyings {
          float4 pos      : SV_POSITION;
          float3 nor      : TEXCOORD0;
          float3 worldPos : TEXCOORD1;
          float3 eye      : TEXCOORD2;
          float3 debug    : TEXCOORD3;
          float2 uv       : TEXCOORD4;
          float  noiseVal : TEXCOORD5;
      };


      //Our vertex function simply fetches a point from the buffer corresponding to the vertex index
      //which we transform with the view-projection matrix before passing to the pixel program.
      varyings vert (uint id : SV_VertexID){

        varyings o;

        int base = id / 6;
        int alternate = id %6;
        if( base < _Count ){

            float3 extra = float3(0,0,0);

            Vert v = _VertBuffer[base % _Count];

          float3 dif = v.start - v.end;
          float3 l = normalize(cross( UNITY_MATRIX_V[2].xyz , normalize(dif)));
          
          float2 uv = float2(0,0);

          float3 fPos; 
          if( alternate == 0 ){ fPos = v.start - l * v.size; uv = float2(0,0); }
          if( alternate == 1 ){ fPos = v.start + l * v.size; uv = float2(1,0); }
          if( alternate == 2 ){ fPos = v.end   + l * v.size; uv = float2(1,1); }
          if( alternate == 3 ){ fPos = v.start - l * v.size; uv = float2(0,0); }
          if( alternate == 4 ){ fPos = v.end   + l * v.size; uv = float2(1,1); }
          if( alternate == 5 ){ fPos = v.end   - l * v.size; uv = float2(0,1); }


            o.worldPos = fPos;//(v.pos) + extra * _Size;///* .001/(.1+length(v.debug));//*(1/(.1+max(length(v.debug),0)));//mul( worldMat , float4( v.pos , 1.) ).xyz;
            //o.debug = v.debug.x;
            o.eye = _WorldSpaceCameraPos - o.worldPos;
          o.nor = normalize( dif );
          o.uv = uv;

            o.pos = mul (UNITY_MATRIX_VP, float4(o.worldPos,1.0f));

        }

        return o;

      }




      //Pixel function returns a solid color for each point.
      float4 frag (varyings v) : COLOR {
          return float4(_Color,1 );
      }

      ENDCG

    }
  }

  Fallback Off


}