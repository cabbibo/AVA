// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'


Shader "Final/BodyPost"
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
			#pragma target 4.5
      #pragma vertex vert
      #pragma fragment frag
      #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight

            
			#include "AutoLight.cginc"
			#include "UnityCG.cginc"
      #include "../Chunks/noise.cginc"
			#include "../Chunks/hsv.cginc"

			// Properties
			sampler2D _MainTex;
			sampler2D _ColorMap;  
			 samplerCUBE _CubeMap;
			float4 _Color;
			float4 _LightColor0; // provided by Unity

			float _RampSize;
			float _RampStart;
    

    struct Vert{

      float3 pos;
      float3 vel;
      float3 nor;
      float3 tang;
      float2 uv;
    
      float used;
    
     
      float3 targetPos;
      float3 bindPos;
      float3 bindNor;
      float3 bindTan;

      float4 boneWeights;
      float4 boneIDs;

      float debug;

    };

    float _HueSize;
    float _HueStart;
    float _HueRandomness;
    float _SparkleHue;
    float _SparkleBright;

    StructuredBuffer<Vert> _TransferBuffer;

         struct vertexOutput
      {
          float4 pos : SV_POSITION;
          float3 normal : NORMAL;
          float2 uv: TEXCOORD0;
          float3 world : TEXCOORD1;
          float3 tan : TEXCOORD2;
          float3 vel : TEXCOORD3;
          float3 closest : TEXCOORD4;
          UNITY_SHADOW_COORDS(5)
      };

	
			vertexOutput vert(uint id : SV_VertexID) {
			


				
                
                vertexOutput output;

UNITY_INITIALIZE_OUTPUT(vertexOutput, output);
				Vert input = _TransferBuffer[id];

				// convert input to world space
				output.pos = mul(UNITY_MATRIX_VP, float4(input.pos,1));
				float4 normal4 = float4(input.nor, 0.0); // need float4 to mult with 4x4 matrix
				output.normal = input.nor;//normalize(mul(normal4, unity_WorldToObject).xyz);
				output.tan = input.tang;//.w * normalize(mul(input.tan, unity_WorldToObject).xyz);
				output.world = input.pos;// mul(unity_ObjectToWorld, input.vertex).xyz;
				output.vel = input.vel;
        output.uv = input.uv;

   UNITY_TRANSFER_SHADOW(output,output.world);
                //TRANSFER_VERTEX_TO_FRAGMENT(output); // shadows
                return output;
			}

			float4 frag(vertexOutput v) : COLOR
			{
				// lighting mode

        float3 dx = ddx( v.world );
        float3 dy = ddy( v.world );
								float3 n = normalize(float3(noise(v.world * 20),
																		noise(v.world * 20+10),
																		noise(v.world * 20+20)));


				float3 fNor = normalize(cross(dx,dy));//v.normal;//normalize(v.normal + noise(float3( v.texCoord.xy * 100  + float2(_Time.y * 1.4 , _Time.y * 2), _Time.y )) * v.tan);
				
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
				//match = (floor(match * 3 ))/3;
				float3 lighting = (.1 + .9 * tex2D(_ColorMap, float2( _RampStart -  match * .4, 0.5)).rgb);// * ramp;
				//lighting = max(lighting,(.1 + .9 * tex2D(_ColorMap, float2( _RampStart - ramp * .5  , 0.5)).rgb));// * ramp;
				
				// sample texture for color
			
				//	lighting = tex2D(_ColorMap,float2(val * .3 + .3,0));//floor(albedo*10)/3;

				float attenuation = LIGHT_ATTENUATION(v); // shadow value
				float3 rgb;// = lighting*attenuation*ramp;//lbedo.rgb * _LightColor0.rgb * lighting * _Color.rgb * attenuation;
				
				//rgb += lighting * .3;//tCol * .2;
				rgb = tCol;//min(floor((attenuation*3))/3 + .1 , ramp);//tex2D(_ColorMap, float2(-attenuation * .9 ,0));
			//rgb = v.tan * .5 + .5;

				//rgb= pow(length(rgb),4)/10;

        fixed shadow = UNITY_SHADOW_ATTENUATION(v,v.world) * .9 + .1 ;

        float reflMatch = dot( eye, refl );
        float4 col = tex2D(_MainTex,v.uv);

                // v.debug.x = life
                // v.debug.y = particleID
                //col.xyz = hsv( sin(v.debug.y) * .1, 1 , 1 );
        
        // Born at life = 0, die at life = 1
        //float life = v.debug.x;
        //float rand = nrand(float2(0, v.debug.y)) * _HueRandomness;
        //float randHueStart = _HueStart + rand;
        //
        //float hue = randHueStart + _HueSize * life;
        //// float hue = _HueStart +_HueSize * life;
        float hue = 1;
        col.xyz = tCol * hsv( match * .4 , 1, 1);

        float rVal = pow( reflMatch , _SparkleBright  ) * _SparkleBright;
       // col.xyz += tCol * hsv(rVal * _SparkleHue, 1,1) ;

          //if( col.a < .1){discard;}
     

          col.xyz= col.xyz * shadow;
				return float4(col.xyz, 1.0);
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
      float3 vel;
      float3 nor;
      float3 tang;
      float2 uv;
    
      float used;
    
     
      float3 targetPos;
      float3 bindPos;
      float3 bindNor;
      float3 bindTan;

      float4 boneWeights;
      float4 boneIDs;

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

struct Vert{

      float3 pos;
      float3 vel;
      float3 nor;
      float3 tang;
      float2 uv;
    
      float used;
    
     
      float3 targetPos;
      float3 bindPos;
      float3 bindNor;
      float3 bindTan;

      float4 boneWeights;
      float4 boneIDs;

      float debug;

    };    	


    StructuredBuffer<Vert> _TransferBuffer;


			  vertexOutput vert( uint id : SV_VertexID)
      {
				vertexOutput output;

				float3 newPos = _TransferBuffer[id].pos;

				// normal extrusion technique
				float3 normal = normalize(_TransferBuffer[id].nor);
				newPos += float4(normal, 0.0) * _OutlineExtrusion;

				// convert to world space
				output.pos = mul(UNITY_MATRIX_VP, float4(newPos, 1));

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
