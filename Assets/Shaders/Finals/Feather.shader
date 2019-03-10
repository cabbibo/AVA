Shader "Final/Feather" {
  Properties {

    _Color ("Color", Color) = (1,1,1,1)
    
    _CubeMap( "Cube Map" , Cube )  = "defaulttexture" {}
    

       _ColorMap ("ColorMap", 2D) = "white" {}
       _SpriteMap ("SpriteMap", 2D) = "white" {}


            _FadeMax( "Fade Max", float ) = 25
    _FadeMin( "Fade Min", float ) = 5
    
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

			struct Vert{
    	  float3 pos;
    	  float3 nor;
    	  float3 tan;
    	  float2 uv;
    	  float debug;
    	};

    	StructuredBuffer<Vert> _TransferBuffer;
      uniform sampler2D _ColorMap;
      uniform sampler2D _SpriteMap;
      samplerCUBE _CubeMap;

      float3 _Color;

      float3 _Player;

      float _FadeMax;
      float _FadeMin;


			struct varyings {
				float4 pos 		: SV_POSITION;
				float3 nor 		: TEXCOORD0;
				float2 uv  		: TEXCOORD1;
				float3 eye      : TEXCOORD2;
				float3 worldPos : TEXCOORD3;
				//float3 debug    : TEXCOORD7;
        //float3 closest    : TEXCOORD8;
        //float3 tan   : TEXCOORD9;
				//float2 sprite   : TEXCOORD11;
				UNITY_SHADOW_COORDS(4)
			};

      #include "../Chunks/hsv.cginc"
			#include "../Chunks/noise.cginc"

			varyings vert(uint id : SV_VertexID) {

				float3 fPos 	= _TransferBuffer[id].pos;
				float3 fNor 	= _TransferBuffer[id].nor;
        float2 fUV 		= _TransferBuffer[id].uv;
        float2 debug  = _TransferBuffer[id].debug;
        float3 fTan   = _TransferBuffer[id].tan;

				varyings o;

				UNITY_INITIALIZE_OUTPUT(varyings, o);

				o.pos = mul(UNITY_MATRIX_VP, float4(fPos,1));
				o.worldPos = fPos;
				o.eye = _WorldSpaceCameraPos - fPos;
				o.nor = fNor;
				o.uv =  fUV;
        //o.sprite = debug;//fUV * (1./6.)+ floor(float2(hash(debug.x*10), hash(debug.x*20)) * 6)/6;
      
        //o.tan = fTan;
				//o.debug = float3(debug.x,debug.y,0);

				UNITY_TRANSFER_SHADOW(o,o.worldPos);

				return o;
			}

			float4 frag(varyings v) : COLOR {
		
				fixed shadow = UNITY_SHADOW_ATTENUATION(v,v.worldPos) * .9 + .1 ;



				float3 dx = ddx(v.worldPos);
				float3 dy = ddy(v.worldPos);


      float pDif = length(_Player - v.worldPos);
      float fadeVal = 1-saturate((pDif - _FadeMin) / (_FadeMax-_FadeMin));

		

			float3 fNor = -normalize(cross(dx*100,dy*100));


				float uvVal = pow( abs(v.uv.x - .5) , 4) * 10 + pow( abs(v.uv.y - .5) , 6) * 100;


				float3 refl = reflect( normalize(v.eye) , fNor );
				float3 cCol=texCUBE(_CubeMap,refl);
				float lM = floor(dot( _WorldSpaceLightPos0 , fNor ) * 100 ) /100;

        float3 col =4* cCol * cCol * cCol * tex2D(_ColorMap,float2(uvVal * .1 + .65 + lM * .1,0));//v.uv.y;//shadow * float3(1,0,1);//v.nor * .5 + .5;//float3(0,1,0);
        return float4( col *  shadow * fadeVal, 1.);
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
      #pragma vertex vert
      #pragma fragment frag
      #pragma multi_compile_shadowcaster
      #pragma fragmentoption ARB_precision_hint_fastest

  #include "UnityCG.cginc"
			struct Vert{
    	  float3 pos;
    	  float3 nor;
    	  float3 tan;
    	  float2 uv;
    	  float debug;
    	};

    	StructuredBuffer<Vert> _TransferBuffer;


sampler2D _MainTex;
  struct v2f {
        V2F_SHADOW_CASTER;
        float2 uv : TEXCOORD1;
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
