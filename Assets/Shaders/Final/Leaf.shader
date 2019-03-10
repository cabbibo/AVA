Shader "Final/Leaf" {
  Properties {

   
  }

	SubShader {
		// COLOR PASS

		Pass {
			Tags{ "LightMode" = "ForwardBase" }

						// Write to Stencil buffer (so that outline pass can read)


			Cull Back

			CGPROGRAM
			#pragma target 4.5
		

			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
      
    	#pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight

      #include "../Chunks/Struct12.cginc"
      
      #include "../Chunks/hsv.cginc"
			#include "../Chunks/safeID.cginc"
			#include "../Chunks/noise.cginc"


      #pragma vertex vert
			#pragma fragment frag
			


			struct varyings {
				float4 pos 		: SV_POSITION;
				float3 nor 		: TEXCOORD0;
				float2 uv  		: TEXCOORD1;
				float3 eye      : TEXCOORD5;
				float3 worldPos : TEXCOORD6;
				float3 debug    : TEXCOORD7;
				float3 closest    : TEXCOORD8;
				UNITY_SHADOW_COORDS(2)
			};

      int _TransferCount;

			varyings vert(uint id : SV_VertexID) {

        //id = safeID(id, _TransferCount);

				float3 fPos 	= _TransferBuffer[id].pos;
				float3 fNor 	= _TransferBuffer[id].nor;
        float2 fUV 		= _TransferBuffer[id].uv;
				float  debug 	= _TransferBuffer[id].debug;

				varyings o;

				UNITY_INITIALIZE_OUTPUT(varyings, o);

				o.pos = mul(UNITY_MATRIX_VP, float4(fPos - fNor * .0004,1));
				o.worldPos = fPos;
				o.eye = _WorldSpaceCameraPos - fPos;
				o.nor = fNor;
				o.uv =  fUV;

				//float n = noise(fPos * _NoiseSize  + float3(0,_Time.y,0));
				o.debug = float3(debug.x,0,0);

				UNITY_TRANSFER_SHADOW(o,o.worldPos);

				return o;
			}

			float4 frag(varyings v) : COLOR {
		
				fixed shadow = UNITY_SHADOW_ATTENUATION(v,v.worldPos );



				float3 nor = v.nor;//-normalize(cross(x,yD));

				float3 col = 1;


        return saturate(float4( col , 1.));
			}

			ENDCG
		}


		/*

		
			SHADOWS


		*/


		  Pass
    {
      Tags{ "LightMode" = "ShadowCaster" }


      Fog{ Mode Off }
      ZWrite On
      ZTest LEqual
      Cull Off
      Offset 1, 1
      CGPROGRAM

      #pragma target 4.5

      #pragma fragmentoption ARB_precision_hint_fastest
      #include "UnityCG.cginc"

      #pragma multi_compile Enable9Struct Enable12Struct Enable16Struct Enable24Struct Enable36Struct
    

      #include "../Chunks/Struct12.cginc"

      #pragma vertex vert
      #pragma fragment frag
      #pragma multi_compile_shadowcaster

      struct v2f {
        V2F_SHADOW_CASTER;
      };


      v2f vert(appdata_base v, uint id : SV_VertexID)
      {
        v2f o;


        float3 wPos = _TransferBuffer[id].pos;
        float3 wNor = _TransferBuffer[id].nor;

            // Default shadow caster pass: Apply the shadow bias.
    float scos = dot(wNor, normalize(UnityWorldSpaceLightDir(wPos)));
    wPos -= wNor * unity_LightShadowBias.z * sqrt(1 - scos * scos);
    o.pos = UnityApplyLinearShadowBias(UnityWorldToClipPos(float4(wPos, 1)));


        //o.pos = mul(UNITY_MATRIX_VP, float4(_TransferBuffer[id].pos + _TransferBuffer[id].nor * -.001, 1));
        return o;
      }

      float4 frag(v2f i) : COLOR
      {
        SHADOW_CASTER_FRAGMENT(i)
      }
      ENDCG
    }




		
	}

}
