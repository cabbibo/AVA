Shader "PostTransfer/Sparkle" {
  Properties {

    _Tex("Texture", 2D) = "white" {}
    
    _HueSize("_HueSize", float ) = 1
    _HueStart("_HueStart", float ) = 1
    _HueRandomness("_HueRandomness", float ) = 1
    
    _SparkleHue("_SparkleHue", float ) = 1
    _SparkleBright("_SparkleBright", float ) = 1

    _CubeMap( "Cube Map" , Cube )  = "defaulttexture" {}

  }

    SubShader {
        // COLOR PASS

        Pass {
            Tags{ "LightMode" = "ForwardBase" }
            Cull Off

            CGPROGRAM
            #pragma target 4.5
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "../Chunks/hsv.cginc"
            
            struct Vert{
                float3 pos;
                float3 vel;
                float3 nor;
                float3 tangent;
                float2 uv;
                float2 debug;
            };

			uniform float _HueSize;
			uniform float _HueStart;
      uniform float _HueRandomness;
      uniform float _SparkleHue;
			uniform float _SparkleBright;

            StructuredBuffer<Vert> _TransferBuffer;

            sampler2D _Tex;

       samplerCUBE _CubeMap;
     

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
                float3 fNor     = _TransferBuffer[id].nor;
                float2 fUV      = _TransferBuffer[id].uv;
                float2 debug    = _TransferBuffer[id].debug;

                varyings o;

                UNITY_INITIALIZE_OUTPUT(varyings, o);

                o.pos = mul(UNITY_MATRIX_VP, float4(fPos,1));
                o.worldPos = fPos;
                o.eye = _WorldSpaceCameraPos - fPos;
                o.nor = fNor;
                o.uv =  fUV;
                o.debug = float3(debug.x,debug.y,0);

                UNITY_TRANSFER_SHADOW(o,o.worldPos);

                return o;
            }

			float nrand(float2 uv)
			{
				return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
			}


            float4 frag(varyings v) : COLOR {
        
                fixed shadow = UNITY_SHADOW_ATTENUATION(v,v.worldPos ) * .9 + .1 ;
                float4 col = tex2D(_Tex,v.uv);

                // v.debug.x = life
                // v.debug.y = particleID
                //col.xyz = hsv( sin(v.debug.y) * .1, 1 , 1 );
				
				// Born at life = 0, die at life = 1
				float life = v.debug.x;
				float rand = nrand(float2(0, v.debug.y)) * _HueRandomness;
				float randHueStart = _HueStart + rand;
				
				float hue = randHueStart + _HueSize * life;
				// float hue = _HueStart +_HueSize * life;

				col.xyz = hsv(hue+length(col.xyz)*.2 , 1, 1);

        float3 refl = normalize( reflect( v.eye,  v.nor ));
        float reflMatch = dot( normalize(v.eye), refl );

        float3 tCol = texCUBE(_CubeMap,refl);

        float rVal = pow( reflMatch , _SparkleBright  ) * _SparkleBright;
        col.xyz += tCol * hsv(rVal * _SparkleHue, 1,1) ;


                if( col.a < .1){discard;}
              return float4( col.xyz * shadow, 1.);
          }

            ENDCG
        }


   // SHADOW PASS

    Pass
    {
      Tags{ "LightMode" = "ShadowCaster" }

      Fog{ Mode Off }
      ZWrite On
      ZTest LEqual
      Cull Off
      Offset 1, 1
      CGPROGRAM

            sampler2D _Tex;
      #pragma target 4.5
      #pragma vertex vert
      #pragma fragment frag
      #pragma multi_compile_shadowcaster
      #pragma fragmentoption ARB_precision_hint_fastest
      #include "UnityCG.cginc"
      #include "../Chunks/StructIfDefs.cginc"

      struct v2f {
        V2F_SHADOW_CASTER;
        float2 uv : TEXCOORD1;
      };


      v2f vert(appdata_base v, uint id : SV_VertexID)
      {
        v2f o;
        o.uv = _TransferBuffer[id].uv;
        o.pos = mul(UNITY_MATRIX_VP, float4(_TransferBuffer[id].pos, 1));
        return o;
      }

      float4 frag(v2f i) : COLOR
      {
        float4 col = tex2D(_Tex,i.uv);
        if( col.a < .1){discard;}
        SHADOW_CASTER_FRAGMENT(i)
      }
      ENDCG
    }
  


    }

}
