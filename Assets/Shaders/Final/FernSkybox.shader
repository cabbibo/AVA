// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Final/FernSkybox" {
   Properties {
      _Cube ("Environment Map", Cube) = "white" {}

		_NoiseSpeed("_NoiseSpeed", float)= 1
		_NoiseSize("_NoiseSize", float)= 1

       _ColorMap ("ColorMap", 2D) = "white" {}

    
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
         float _NoiseSpeed;
         float _NoiseSize;
         sampler2D _ColorMap;

         struct vertexInput {
            float4 vertex : POSITION;
            float3 texcoord : TEXCOORD0;
         };

         struct vertexOutput {
            float4 vertex : SV_POSITION;
            float3 texcoord : TEXCOORD0;
         };

         vertexOutput vert(vertexInput input)
         {
            vertexOutput output;
            output.vertex = UnityObjectToClipPos(input.vertex);
            output.texcoord = input.texcoord;
            return output;
         }

         fixed4 frag (vertexOutput input) : COLOR
         {

         		

         		float3 n =  normalize(float3( noise(input.texcoord*.3 * _NoiseSize+ input.texcoord*.6*_NoiseSize + 100 + .2*_Time.y*_NoiseSpeed) , noise(input.texcoord*5* _NoiseSize + input.texcoord*1*_NoiseSize + 200+ .4*_Time.y*_NoiseSpeed) , noise(input.texcoord*4* _NoiseSize+ input.texcoord*1*_NoiseSize + 300+.6* _Time.y*_NoiseSpeed) ) -.5) - 10*input.texcoord;

         		n = normalize(n);

         		float3 refrR = refract(input.texcoord , n , .5);
         		float3 refrG = refract(input.texcoord , n , .4);
         		float3 refrB = refract(input.texcoord , n , .3);



         		float3 og = texCUBE(_Cube, refract(input.texcoord , n , .6));
         		float3 tCol =  float3( texCUBE (_Cube, refrR ).x , texCUBE (_Cube, refrG ).y , texCUBE(_Cube,refrB).z );// - texCUBE(_Cube, refrB ).x ;
         		float3 col;// = saturate(smoothstep(abs(tCol * 1) , .0, .05));//hsv( tCol.x * .6 + _Time.y * .2 ,.4,1.1);// * abs(sin(tCol.x * 10 + _Time.y * 1.23)) + hsv( tCol.y * .2 + _Time.y * .44 + .3 ,1,1) * sin(tCol.y*20+ _Time.y * 1.27)  + hsv( tCol.z * .2 + _Time.y * .47 + .6 ,1,1)* sin(tCol.z*10 + _Time.y * 1.3)  ;
         	 	//col = hsv(tCol.x * .3,.8,.4);//hsv( tCol.x * .6 + _Time.y * .2 ,.4,1.1);// * abs(sin(tCol.x * 10 + _Time.y * 1.23)) + hsv( tCol.y * .2 + _Time.y * .44 + .3 ,1,1) * sin(tCol.y*20+ _Time.y * 1.27)  + hsv( tCol.z * .2 + _Time.y * .47 + .6 ,1,1)* sin(tCol.z*10 + _Time.y * 1.3)  ;

         	 	col = tex2D(_ColorMap, float2(length(tCol)  +.73,0.5));
         		//col = normalize(col);

         		col = float3(1,1,1);//(og-tCol) * col;
            return saturate(float4(col,1));
         }
         ENDCG 
      }
   } 	
}