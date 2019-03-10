// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Final/FeatherSkybox" {
   Properties {
      _Cube ("Environment Map", Cube) = "white" {}
      _Paint ("Paint Texture", 2D) = "white" {}
      _ColorMap ("ColorMap Texture", 2D) = "white" {}
   }

   SubShader {
      Tags { "Queue"="Background"  }

      Pass {
         ZWrite Off 
         Cull Off

         CGPROGRAM
         #pragma vertex vert
         #pragma fragment frag
         #pragma target 4.5

         #include "../Chunks/hsv.cginc"
         #include "../Chunks/noise.cginc"


         // User-specified uniforms
         samplerCUBE _Cube;
         sampler2D  _Paint;
         sampler2D  _ColorMap;

         struct vertexInput {
            float4 vertex : POSITION;
            float3 texcoord : TEXCOORD0;
         };

         struct vertexOutput {
            float4 vertex : SV_POSITION;
            float3 texcoord : TEXCOORD0;
            float3 world : TEXCOORD1;
         };

         vertexOutput vert(vertexInput input)
         {
            vertexOutput output;
            output.vertex = UnityObjectToClipPos(input.vertex);
            output.world = mul( unity_ObjectToWorld, input.vertex).xyz;
            output.texcoord = input.texcoord;
            return output;
         }


         fixed4 frag (vertexOutput input) : COLOR
         {


            return saturate(float4(1,1,1,1));
         }
         ENDCG 
      }
   } 	
}