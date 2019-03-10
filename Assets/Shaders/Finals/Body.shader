// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'


Shader "Final/Body"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_ColorMap("Ramp", 2D) = "white" {}
		_Color("Color", Color) = (1, 1, 1, 1)
		_OutlineExtrusion("Outline Extrusion", float) = 0
		_OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
		_RampStart("Start", float)= 0
		_CubeMap( "Cube Map" , Cube )  = "defaulttexture" {}
    
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

			// Write to Stencil buffer (so that outline pass can read)
			Stencil
			{
				Ref 4
				Comp always
				Pass replace
				ZFail keep
			}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase // shadows
			#include "AutoLight.cginc"
			#include "UnityCG.cginc"
			#include "../Chunks/noise.cginc"

			// Properties
			sampler2D _MainTex;
			sampler2D _ColorMap;  
			 samplerCUBE _CubeMap;
			float4 _Color;
			float4 _LightColor0; // provided by Unity

			float _RampSize;
			float _RampStart;


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
				float3 texCoord : TEXCOORD0;
				float3 world : TEXCOORD3;
				float3 tan : TEXCOORD4;
				LIGHTING_COORDS(1,2) // shadows
			};

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;

				// convert input to world space
				output.pos = UnityObjectToClipPos(input.vertex);
				float4 normal4 = float4(input.normal, 0.0); // need float4 to mult with 4x4 matrix
				output.normal = normalize(mul(normal4, unity_WorldToObject).xyz);
				output.tan = input.tan.w * normalize(mul(input.tan, unity_WorldToObject).xyz);
				output.world = mul(unity_ObjectToWorld, input.vertex).xyz;
				output.texCoord = input.texCoord;


                TRANSFER_VERTEX_TO_FRAGMENT(output); // shadows
				return output;
			}

			float4 frag(vertexOutput v) : COLOR
			{
				// lighting mode


								float3 n = normalize(float3(noise(v.world * 20),
																		noise(v.world * 20+10),
																		noise(v.world * 20+20)));


				float3 fNor = v.normal;//normalize(v.normal + noise(float3( v.texCoord.xy * 100  + float2(_Time.y * 1.4 , _Time.y * 2), _Time.y )) * v.tan);
				
				// convert light direction to world space & normalize
				// _WorldSpaceLightPos0 provided by Unity
				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

				// finds location on ramp texture that we should sample
				// based on angle between surface normal and light direction
				float ramp = clamp(dot(fNor, lightDir), 0, 1.0);
		
				float3 eye = normalize(_WorldSpaceCameraPos - v.world);
				float3 refl = reflect( eye , fNor );


				float match = dot( eye , fNor );


				float3 tCol = texCUBE(_CubeMap,refl);

				ramp = (floor(ramp * 3 ))/3;
				match = (floor(match * 3 ))/3;
				float3 lighting = (.1 + .9 * tex2D(_ColorMap, float2( _RampStart -  match * .4, 0.5)).rgb);// * ramp;
				//lighting = max(lighting,(.1 + .9 * tex2D(_ColorMap, float2( _RampStart - ramp * .5  , 0.5)).rgb));// * ramp;
				
				// sample texture for color
				float4 albedo = tex2D(_MainTex, v.texCoord.xy );

				float val = floor(pow(albedo.y,.5)*8)/3;
				lighting = tex2D(_ColorMap,float2(val * .3 + .3,0));//floor(albedo*10)/3;

				float attenuation = LIGHT_ATTENUATION(v); // shadow value
				float3 rgb = lighting*attenuation*ramp;//lbedo.rgb * _LightColor0.rgb * lighting * _Color.rgb * attenuation;
				
				rgb += lighting * .3;//tCol * .2;
				rgb = min(floor((attenuation*3))/3 + .1 , ramp);//tex2D(_ColorMap, float2(-attenuation * .9 ,0));
			//rgb = v.tan * .5 + .5;

				//rgb= pow(length(rgb),4)/10;

				return float4(rgb, 1.0);
			}

			ENDCG
		}

		// Shadow pass
		Pass
    	{
            Tags 
			{
				"LightMode" = "ShadowCaster"
			}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

            struct v2f { 
                V2F_SHADOW_CASTER;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
    	}

		// Outline pass
		Pass
		{
			// Won't draw where it sees ref value 4
			Cull OFF
			ZWrite ON
			ZTest ON
			Stencil
			{
				Ref 4
				Comp notequal
				Fail keep
				Pass replace
			}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			// Properties
			uniform float4 _OutlineColor;
			uniform float _OutlineSize;
			uniform float _OutlineExtrusion;
			uniform float _OutlineDot;

			struct vertexInput
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float4 color : COLOR;
			};

			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;

				float4 newPos = input.vertex;

				// normal extrusion technique
				float3 normal = normalize(input.normal);
				newPos += float4(normal, 0.0) * _OutlineExtrusion;

				// convert to world space
				output.pos = UnityObjectToClipPos(newPos);

				output.color = _OutlineColor;
				return output;
			}

			float4 frag(vertexOutput input) : COLOR
			{
				// checker value will be negative for 4x4 blocks of pixels
				// in a checkerboard pattern
				//input.pos.xy = floor(input.pos.xy * _OutlineDot) * 0.5;
				//float checker = -frac(input.pos.r + input.pos.g);

				// clip HLSL instruction stops rendering a pixel if value is negative
				//clip(checker);

				return input.color;
			}

			ENDCG
		}
	}
}