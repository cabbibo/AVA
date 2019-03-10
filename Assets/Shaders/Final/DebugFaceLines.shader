// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'


Shader "Final/DebugFaceLines"
{
	Properties
	{
		_OutlineExtrusion("Outline Extrusion", float) = 0
		_OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
		_ShinyBlend("_ShinyBlend", float)= 0
		_Saturation("_Saturation", float)= 1
		_Lightness("_Lightness", float)= 1
		_UVHueSize("_UVHueSize", float)= 1
		_ColorOffset("_ColorOffset", float)= 1
		_NormalSize("_NormalSize", float)= 1
		_NoiseSize("_NoiseSize", float)= 1
		_ShadowSize("_ShadowSize", float)= 1
		_ShadowDarkness("_ShadowDarkness", float)= 1
		_CubeMap( "Cube Map" , Cube )  = "defaulttexture" {}

			    _MainTex ("Texture", 2D) = "white" {}

       _ColorMap ("ColorMap", 2D) = "white" {}

    
	}

	SubShader
	{
		// Regular color & lighting pass
		Pass
		{
            Tags
			{ 
				"LightMode" = "ForwardBase" // allows shadow rec/cast
			}

	
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.5
			#pragma multi_compile_fwdbase // shadows
			#include "AutoLight.cginc"
			#include "UnityCG.cginc"
			#include "../Chunks/noise.cginc"
			#include "../Chunks/hsv.cginc"

			// Properties

			 samplerCUBE _CubeMap;
			float4 _LightColor0; // provided by Unity

      sampler2D _MainTex;
      sampler2D _ColorMap;

			float _NormalSize;
			float _UVHueSize;
			float _ColorOffset;
			float _Saturation;
			float _Lightness;
			float _ShadowDarkness;
			float _ShadowSize;
			float _NoiseSize;
			float _ShinyBlend;


			struct vertexInput
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tan : TANGENT;
				float3 texCoord : TEXCOORD0;
			};

			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float3 normal : NORMAL;
				float3 uv : TEXCOORD0;
				float3 world : TEXCOORD3;
				float3 tan : TEXCOORD4;
			};

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;

				// convert input to world space
				output.pos = UnityObjectToClipPos(input.vertex-float3(0,0,-.003));
				float4 normal4 = float4(input.normal, 0.0); // need float4 to mult with 4x4 matrix
				output.normal = normalize(mul(normal4, unity_WorldToObject).xyz);
				output.tan = input.tan.w * normalize(mul(input.tan, unity_WorldToObject).xyz);
				output.world = mul(unity_ObjectToWorld, input.vertex).xyz;
				output.uv = input.texCoord;


         
				return output;
			}





			float4 frag(vertexOutput v) : COLOR
			{
				float3 rgb = float3(1,1,1);//  (attenuation * .5 + .5);//attenuation * .2;////rgb * ( tCol  * _ShinyBlend + (1-_ShinyBlend)) * 1.4;
				return saturate(float4(rgb, 1.0));
			}

			ENDCG
		}

	

		
	}
}