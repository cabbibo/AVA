Shader "PostTransfer/BasicSprite" {
  Properties {

    _Tex("", 2D) = "white" {}
    _Color ("Color", Color) = (1,1,1,1)

		_CubeMap( "Cube Map" , Cube )  = "defaulttexture" {}
    
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
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight

			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "../Chunks/StructIfDefs.cginc"
			#include "../Chunks/hsv.cginc"


			sampler2D _Tex;
			samplerCUBE _CubeMap;
      float3 _Color;


			struct varyings {
				float4 pos 		: SV_POSITION;
				float3 nor 		: TEXCOORD0;
				float2 uv  		: TEXCOORD1;
				float3 eye      : TEXCOORD5;
				float3 worldPos : TEXCOORD6;
				float3 debug    : TEXCOORD7;
				float3 tan    : TEXCOORD9;
				float3 up    : TEXCOORD10;
				float3 closest    : TEXCOORD8;
				UNITY_SHADOW_COORDS(2)
			};

			varyings vert(uint id : SV_VertexID) {

				float3 fPos 	= _TransferBuffer[id].pos;
				float3 fNor 	= _TransferBuffer[id].nor;
        float2 fUV 		= _TransferBuffer[id].uv;
				float2 debug 	= _TransferBuffer[id].debug;

				varyings o;

				UNITY_INITIALIZE_OUTPUT(varyings, o);

				o.pos = mul(UNITY_MATRIX_VP, float4(fPos,1));
				o.worldPos = fPos;
				o.eye = _WorldSpaceCameraPos - fPos;
				o.nor = fNor;
				o.uv =  fUV;
				o.tan = _TransferBuffer[id].tan;
				o.up = normalize(cross(_TransferBuffer[id].tan , fNor));
				o.debug = float3(debug.x,debug.y,0);

				UNITY_TRANSFER_SHADOW(o,o.worldPos);

				return o;
			}

			float4 frag(varyings v) : COLOR {
		
				fixed shadow = UNITY_SHADOW_ATTENUATION(v,v.worldPos -v.nor ) * .9 + .1 ;
				float rW = floor(abs(sin(v.debug.x) * 6))/6;
				float rH = floor(abs(sin(v.debug.x*10) * 6))/6;
				float4 t = tex2D(_Tex,v.uv/6 + float2(rW,rH));

				float3 col = hsv( t,1,1);

				float x = pow((v.uv.x  -.5),1);
				float y = pow((v.uv.y  -.5),1);

				float3 newNor =  normalize(v.nor - .5 * v.tan * y  + .5 * v.up *x);
				float3 refl = normalize(reflect( normalize(v.eye) , newNor));
				float3 cCol = texCUBE(_CubeMap,refl);
				float3 hCol =  refl * .5 + .5;
				col = hCol * 2 * cCol;
				if( length(v.uv-float2(.5,.5)) > .5){discard;}
				if( length(v.uv-float2(.5,.5)) > .45){col = float3(0,0,0);}
        return float4(col * shadow, 1.);
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
        float3 debug : TEXCOORD2;
      };


      v2f vert(appdata_base v, uint id : SV_VertexID)
      {
        v2f o;
        o.uv = _TransferBuffer[id].uv;
        o.pos = mul(UNITY_MATRIX_VP, float4(_TransferBuffer[id].pos, 1));

				float2 debug 	= _TransferBuffer[id].debug;

        o.debug = float3(debug.x,debug.y,0);
        return o;
      }

      float4 frag(v2f v) : COLOR
      {
      					float rW = floor(abs(sin(v.debug.x) * 6))/6;
				float rH = floor(abs(sin(v.debug.x*10) * 6))/6;
				float4 col = tex2D(_Tex,v.uv/6 + float2(rW,rH));

				//if( length(col.x) > .5){discard;}
					if( length(v.uv-float2(.5,.5)) > .5){discard;}
        SHADOW_CASTER_FRAGMENT(i)
      }
      ENDCG
    }
  


	}

}
