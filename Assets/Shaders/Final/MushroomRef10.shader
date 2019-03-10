Shader "Final/Mushroom10" {
  Properties {

    _Color ("Color", Color) = (1,1,1,1)
    _HueStart("Hue Start",float) = 0
    _HueSize("Hue Size",float) = .2
    _HueOffset("Hue Offset",float) = .2
    _Saturation("Saturation",float) = .8
    _HueSpeed("HueSpeed",float) = .3
    _HueOsscilation("_HueOsscilation",float) = .3
    _LightHueSize("_LightHueSize",float) = .3
    _NoiseSize("_NoiseSize",float) = 100
    _NoiseSpeed("_NoiseSpeed",float) = 100
    _NoiseAmount("_NoiseAmount",float) = .3
    _Lightness("_Lightness",float) = 1
    _NoiseBandVal("_NoiseBandVal",float) = 20
    _ShadowHue("_ShadowHue",float) = 1
    _ShadowDarkness("_ShadowDarkness",float) = 1
    _IdHueDif("_IdHueDif",float) = 1

    _OutlineOut("OutlineOut", float) = .0004 
    _OutlineHueSize("_OutlineHueSize", float) = .1
    _OutlineHueSpeed("_OutlineHueSpeed", float) = .1
    _OutlineHueOsscilation("_OutlineHueOsscilation", float) = .1
    _OutlineNoiseAmount("_OutlineNoiseAmount", float) = .1
    _OutlineNoiseSize("_OutlineNoiseSize", float) = 100
    _OutlineNoiseSpeed("_OutlineNoiseSpeed", float) = 100
    _OutlineSaturation("_OutlineSaturation", float) = .6  
    _OutlineLightness("_OutlineLightness", float) = 1
   
  }

	SubShader {
		// COLOR PASS

		Pass {
			Tags{ "LightMode" = "ForwardBase" }

						// Write to Stencil buffer (so that outline pass can read)
			Stencil
			{
				Ref 3
				Comp always
				Pass replace
				ZFail keep
			}

			Cull Off

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
			


			
      float3 _Color;
      float _HueSize;
      float _HueStart;
      float _HueOffset;
      float _Saturation;
      float _NoiseSize;
      float _NoiseAmount;
      float _NoiseSpeed;
      float _NoiseBandVal;

      float _LightHueSize;
      float _HueOsscilation;
      float _HueSpeed;
      float _Lightness;
      float _IdHueDif;

      float _ShadowHue;
      float _ShadowDarkness;
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

        int nId = id;//safeID(id, _TransferCount);

				float3 fPos 	= _TransferBuffer[nId].pos;
				float3 fNor 	= _TransferBuffer[nId].nor;
        float2 fUV 		= _TransferBuffer[nId].uv;
				float  debug 	= _TransferBuffer[nId].debug;

				varyings o;

				//UNITY_INITIALIZE_OUTPUT(varyings, o);

				o.pos = mul(UNITY_MATRIX_VP, float4(fPos,1));
				o.worldPos = fPos;
				o.eye = _WorldSpaceCameraPos - fPos;
				o.nor = fNor;
				o.uv =  fUV;

				float n = noise(fPos * _NoiseSize  + float3(0,_Time.y,0));
				o.debug = float3(debug.x,n,0);

				UNITY_TRANSFER_SHADOW(o,o.worldPos);

				return o;
			}

			float4 frag(varyings v) : COLOR {
		
				fixed shadow = UNITY_SHADOW_ATTENUATION(v,v.worldPos );

          float3 x = ddx(v.worldPos);
        float3 yD = ddy(v.worldPos);

        //float3 nor = v.nor;//-normalize(cross(x,yD));
				float3 nor = -normalize(cross(x,yD));

				float3 lDir = normalize(v.worldPos - _LightPos);
				float3 refl = reflect( normalize(lDir) , nor );
				float m = pow(dot( normalize(v.eye) , refl ) ,2);// * _HueOffset;
				m *= 2;

				float m2 = - dot( lDir , nor );// * _HueOffset;
				//m2 *= 2;

				float n = noise(v.worldPos *_NoiseSize * .3 + float3(0,_Time.y * _NoiseSpeed,0));

				n = sin(n * _NoiseBandVal);

				float3 col = hsv(  v.debug.x * .1+ 1 * _IdHueDif +  (1-shadow) * _ShadowHue  + _HueOffset  + length(v.worldPos - _LightPos) * _LightHueSize + ( v.uv.y) * _HueSize + n * _NoiseAmount  + _HueStart + _HueOffset * v.debug.x * .2+  sin(_HueSpeed * _Time.y ) * _HueOsscilation , _Saturation  * .6,_Lightness );// / length(v.worldPos - _LightPos); //float3( m , ;//hsv( m  + v.debug.x*_HueSize + _HueStart,_Saturation,1)* shadow;
		
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
