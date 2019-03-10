// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Final/GrassSkybox" {
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


         float3 triplanar(  float3 dir , float size ){

         	float3 p1 = tex2D( _Paint , size * dir.zy ).xyz;
         	float3 p2 = tex2D( _Paint , size * dir.xz ).xyz;
         	float3 p3 = tex2D( _Paint , size * dir.xy ).xyz;


         	float3 blend = abs(dir);
         	blend /= blend.x + blend.y + blend.z;


         	return p1 * blend.x + p2 * blend.y + p3 * blend.z;

         }





float4 doTextureSample( float2 pUV , float size , float noise , float noiseSize){

 float2 pivot = .5;

            float2 uvMul = (size * pUV ) * (1 + noise * sin(pUV.x * noiseSize))  * (1 + noise * sin(pUV.y * noiseSize));
         		
            float idX = floor( uvMul.x );
            float idY = floor( uvMul.y );

            uvMul = abs(uvMul);

         		float2 uv =  uvMul % 1  + .5;

         		float h = floor(hash(idX * 4) * 6 )/6;
         		float h1 = floor(hash(idY* 10) * 6)/6;

         		float2 offset = float2(h,h1);


       			float sinX = sin (_Time.y * .1 * sin(100*idX + 100 * idY) );
       			float cosX = cos (_Time.y * .1 * sin(100*idX + 100 * idY));

            float2x2 rotationMatrix = float2x2( cosX, -sinX, sinX, cosX);

            uv = mul ( uv - pivot * 2 , rotationMatrix );
            uv += pivot;


            float oob = 0;
            if( uv.x > 1 || uv.x < 0 || uv.y > 1 || uv.y < 0 ){
            	oob = 1;
            }

            float v = length(uv-.5);

            v = 1 - 2*v;


// 5 3
// 3 1
// 4 1 
// 5 1

float hVal = floor( hash(100*sin(idX*1212)+100*sin(idY*1021)) * 6 );
float hVal2 = floor( hash(100*sin(idX*12)+100*sin(idY*21)) * 6 );
            uv /= 6;
            uv += float2((1./6), (1./6)) * float2(hVal,hVal2);//offset;

         		float4 col = tex2D( _Paint ,uv);


         		col *= (1-oob) * saturate( v *  4);
         		
         		return col * col.a;

}
         fixed4 frag (vertexOutput input) : COLOR
         {


         	float3 n = input.texcoord;
        float r = pow((n.x * n.x)
                        + (n.y * n.y)
                        + (n.z * n.z),.5);
        float a0 = atan(n.z / n.x);
        if (n.x < 0)
            a0 += 3.14159;
        float a1 = asin(n.y / r);



         		float3 tCol =  texCUBE (_Cube, input.texcoord );

         		float3 pCol =  tex2D (_Paint, input.texcoord.xy  );
         		float3 col;


         		float2 polarUV = float2(a0,a1);// * .5;

         		float4 t1 = doTextureSample( polarUV , 20 / 3.14159,.01 , 40/3.14159 );
         		t1 = max(t1,doTextureSample( polarUV + float2(.41,.5411), 20 / 3.14159, .01 , 40/3.14159));
         		t1 = max(t1,doTextureSample( polarUV + float2(.61,.311), 20 / 3.14159, .01 , 40/3.14159));
         		//t1 = max(t1,doTextureSample( polarUV + float2(.2,.4), 8  * 3.14159 , .001 , 4 * 3.14159 ));

         		col =   tex2D(_ColorMap, float2(length(t1.xyz)*.4 + .2 + input.texcoord.x,0)) *t1.a ;//hsv(t1.x * 1 + .3,1,1);


         		//col = normalize(col);
            return saturate(float4(col.xyz,1));
         }
         ENDCG 
      }
   } 	
}