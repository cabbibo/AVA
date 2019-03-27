Shader "Finals/Cold"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent"}
		LOD 100
		GrabPass{
		}
		Pass
		{


			//Cull Front
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog

			
			#include "UnityCG.cginc"
			#include "../Chunks/Struct16.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 screenUV : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _GrabTexture;// builtin uniform for grabbed texture
			
			v2f vert (uint id : SV_VertexID)
			{
				v2f o;

				Vert v = _TransferBuffer[id];
				o.vertex = mul( UNITY_MATRIX_VP , float4(v.pos,1));//UnityObjectToClipPos(v.v);
				o.uv = v.uv;//TRANSFORM_TEX(v.uv, _MainTex);
				o.screenUV = ComputeGrabScreenPos(o.vertex);
				return o;
			}
			
			fixed4 frag (v2f v) : SV_Target
			{

				float2 offset = v.uv - float2(.5,.5);

				float edge = (.5 - length(offset)) / .5;
				//edge = pow( edge ,20);

				float4 tCol = tex2D(_MainTex, v.uv);

				if( length( offset ) > .5 ){ discard; }
				fixed4 grab = tex2Dproj(_GrabTexture, v.screenUV+.1*edge*float4(tCol.x-.5 , tCol.y-.5,0,0));// + float4( sin((_Time.x * 10)+i.screenUV.x*32.0)*0.1, 0, 0, 0));
				//grab = tCol;
				grab += dot( tCol.xyz , float3(0,1,0)) * edge;
				return grab;
			}
			ENDCG
		}
	}
}
