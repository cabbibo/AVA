Shader "Final/Basic12" {
  Properties {

		_Color("_Color",Color)=(1,0,0,1)
    
  }

	SubShader {
		// COLOR PASS

		Pass {
			Tags{ "LightMode" = "ForwardBase" }
			Cull Off


						// Write to Stencil buffer (so that outline pass can read)
			Stencil
			{
				Ref 10
				Comp always
				Pass replace
				ZFail keep
			}

			CGPROGRAM
			#pragma target 4.5
			#include "UnityCG.cginc"
      #include "../Chunks/Struct12.cginc"
			#include "../Chunks/safeID.cginc"


      #pragma vertex vert
			#pragma fragment frag
			
			float3 _Color;

			struct varyings {
				float4 pos 		: SV_POSITION;
				float3 nor 		: TEXCOORD0;
			};

      int _TransferCount;

			varyings vert(uint id : SV_VertexID) {

        //id = safeID(id, _TransferCount);

				float3 fPos 	= _TransferBuffer[id].pos;
				float3 fNor 	= _TransferBuffer[id].nor;

				varyings o;

				UNITY_INITIALIZE_OUTPUT(varyings, o);

				o.pos = mul(UNITY_MATRIX_VP, float4(fPos,1));
				o.nor = normalize(fNor);

				return o;
			}

			float4 frag(varyings v) : COLOR {
				return float4( _Color , 1.);
			}

			ENDCG
		}

}



	}

