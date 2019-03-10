Shader "Post/FernFern" {
  Properties {

		_CubeMap( "Cube Map" , Cube )  = "defaulttexture" {}
    
    [Toggle(Enable9Struct)]  _Struct9("9 Struct", Float) = 0
    [Toggle(Enable12Struct)] _Struct12("12 Struct", Float) = 0
    [Toggle(Enable16Struct)] _Struct16("16 Struct", Float) = 0
    [Toggle(Enable24Struct)] _Struct24("24 Struct", Float) = 0
    [Toggle(Enable36Struct)] _Struct36("36 Struct", Float) = 0
  }

	SubShader {
		// COLOR PASS

		Pass {
			Tags{ "LightMode" = "ForwardBase" }
			Cull Off

			CGPROGRAM
			#pragma target 4.5
		

			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
      
#pragma multi_compile Enable9Struct Enable12Struct Enable16Struct Enable24Struct Enable36Struct
    #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight

      #include "../Chunks/StructIfDefs.cginc"
      
      #include "../Chunks/hsv.cginc"
			#include "../Chunks/safeID.cginc"


      #pragma vertex vert
			#pragma fragment frag
			

			samplerCUBE _CubeMap;

      float3 _LightPos;
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
				float2 debug 	= _TransferBuffer[id].debug;

				varyings o;

				UNITY_INITIALIZE_OUTPUT(varyings, o);

				o.pos = mul(UNITY_MATRIX_VP, float4(fPos,1));
				o.worldPos = fPos;
				o.eye = _WorldSpaceCameraPos - fPos;
				o.nor = normalize(fNor);
				o.uv =  fUV;
				o.debug = float3(debug.x,debug.y,0);

				UNITY_TRANSFER_SHADOW(o,o.worldPos);

				return o;
			}

			float4 frag(varyings v) : COLOR {
		
				fixed shadow = UNITY_SHADOW_ATTENUATION(v,v.worldPos ) * .6 + .4;
				float3 refl = reflect( normalize( v.eye) , v.nor);

				float3 tCol = 	2*texCUBE(_CubeMap , refl ) * (v.nor * .3 + .89);
       
				float3 col = tCol*tCol * hsv( v.uv.x * .4 + v.debug.x * .4 + v.debug.y * 10 , .7,1);
				return float4( col * shadow, 1.);
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

      #pragma target 4.5

      #pragma fragmentoption ARB_precision_hint_fastest
      #include "UnityCG.cginc"

      #pragma multi_compile Enable9Struct Enable12Struct Enable16Struct Enable24Struct Enable36Struct
    

      #include "../Chunks/StructIfDefs.cginc"

      #pragma vertex vert
      #pragma fragment frag
      #pragma multi_compile_shadowcaster

      struct v2f {
        V2F_SHADOW_CASTER;
      };


      v2f vert(appdata_base v, uint id : SV_VertexID)
      {
        v2f o;
        o.pos = mul(UNITY_MATRIX_VP, float4(_TransferBuffer[id].pos, 1));
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

