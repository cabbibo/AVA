Shader "Final/FeatherParticles" {
  Properties {

    _Color ("Color", Color) = (1,1,1,1)
  }

    SubShader {
        // COLOR PASS

        Pass {
            Tags{ "LightMode" = "ForwardBase" }
            Cull Off

            // Write to Stencil buffer (so that outline pass can read)
      Stencil
      {
        Ref 5
        Comp always
        Pass replace
        ZFail keep
      }

            CGPROGRAM
            #pragma target 4.5
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "../Chunks/Struct16.cginc"
      #include "../Chunks/hsv.cginc"
            #include "../Chunks/hash.cginc"

      float3 _Color;

      float _BaseHue;

            struct varyings {
                float4 pos      : SV_POSITION;
                float3 nor      : TEXCOORD0;
                float2 uv       : TEXCOORD1;
                float3 eye      : TEXCOORD5;
                float3 worldPos : TEXCOORD6;
        float3 debug    : TEXCOORD7;
                float3 closest    : TEXCOORD8;
                UNITY_SHADOW_COORDS(2)
            };

            varyings vert(uint id : SV_VertexID) {

                float3 fPos     = _TransferBuffer[id].pos;
        float3 fNor   = _TransferBuffer[id].nor;
        float2 fUV      = _TransferBuffer[id].uv;
                float2 debug    = _TransferBuffer[id].debug;

                varyings o;

                UNITY_INITIALIZE_OUTPUT(varyings, o);

                o.pos = mul(UNITY_MATRIX_VP, float4(fPos,1));
                o.worldPos = fPos;
                o.eye = _WorldSpaceCameraPos - fPos;
        o.nor = fNor;

        //float offset = floor(hash(debug.x) * 6) /6;



        float2 offset = floor( float2(sin(debug.x*.04 + 10),sin(debug.x * .04)) *2 ) /2; 

                o.uv =  fUV * .5  + offset;//fUV.yx * float2(1./6.,.999) + float2(offset,0);
                o.debug = float3(debug.x,debug.y,0);

                UNITY_TRANSFER_SHADOW(o,o.worldPos);

                return o;
            }

            float4 frag(varyings v) : COLOR {

          return float4( _Color, 1.);
            }

            ENDCG
        }




    }

}


