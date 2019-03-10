Shader "Final/DandelionBackground"
{
	Properties
	{
    	_textureY ("TextureY", 2D) = "white" {}
      _textureCbCr ("TextureCbCr", 2D) = "black" {}
      _MainTex( "Main" , 2D ) = "white" {}
	}
	SubShader
	{
		Cull Off
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
            ZWrite Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			
            float4x4 _UnityDisplayTransform;

			struct Vertex
			{
				float4 position : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct TexCoordInOut
			{
				float4 position : SV_POSITION;
				float2 texcoord : TEXCOORD0;
				float2 uv : TEXCOORD1;
			};

			TexCoordInOut vert (Vertex vertex)
			{
				TexCoordInOut o;
				o.position = UnityObjectToClipPos(vertex.position); 


				float texX = vertex.texcoord.x;
				float texY = vertex.texcoord.y;
				
				o.texcoord.x = (_UnityDisplayTransform[0].x * texX + _UnityDisplayTransform[1].x * (texY) + _UnityDisplayTransform[2].x);
 			 	o.texcoord.y = (_UnityDisplayTransform[0].y * texX + _UnityDisplayTransform[1].y * (texY) + (_UnityDisplayTransform[2].y));
	            
	      o.uv = vertex.position.xy; //texX;
	      //o.uv.y = texY;

				return o;
			}
			
            // samplers
            sampler2D _textureY;
            sampler2D _textureCbCr;
            sampler2D _MainTex;

			fixed4 frag (TexCoordInOut i) : SV_Target
			{
				// sample the texture
                float2 texcoord = i.texcoord;
                float y = tex2D(_textureY, texcoord).r;
                float4 ycbcr = float4(y, tex2D(_textureCbCr, texcoord).rg, 1.0);

				const float4x4 ycbcrToRGBTransform = float4x4(
						float4(1.0, +0.0000, +1.4020, -0.7010),
						float4(1.0, -0.3441, -0.7141, +0.5291),
						float4(1.0, +1.7720, +0.0000, -0.8860),
						float4(0.0, +0.0000, +0.0000, +1.0000)
					);

				float4 c = mul(ycbcrToRGBTransform, ycbcr);
				//c.xyz = sin( length( c.xyz ) * 4) * c.xyz;

				float4 t = tex2D(_MainTex, length(c.xyz) * 10 );

				//if( length( t.xyz ) < 1.14 ){ c.xyz = t.xyz; }
        return length(t)*c;
			}
			ENDCG
		}
	}
}
