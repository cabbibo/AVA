Shader "PostProcessing/BWPass" {
 Properties {
 _MainTex ("Base (RGB)", 2D) = "white" {}
 _BW("Black & White blend", Range (0, 1)) = 0
 _keepColor ("KeepColor", Range (0, 1)) = 0
 }
 SubShader {
 Pass {
   Tags {"Queue"="Transparent" "RenderType"="Transparent" }

    ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
 CGPROGRAM
 #pragma vertex vert_img
 #pragma fragment frag
 
 #include "UnityCG.cginc"
 #include "../Chunks/hsv.cginc"
 
 uniform sampler2D _MainTex;
 uniform float _Width;
 uniform float _Height;


float4 S( float x , float y , float2 uv ){
	float2 delta = float2( 1*x / _Width , 1*y / _Height);
	return tex2D(_MainTex, uv + delta);
}


float _BW;
float _keepColor;


 float4 frag(v2f_img i) : COLOR {
 float4 c = tex2D(_MainTex, i.uv);

 float4 L = S( -1 , 0 , i.uv);
 float4 R = S( 1 , 0 , i.uv);
 float4 U = S( 0 , 1 , i.uv);
 float4 D = S( 0 , -1 , i.uv);

 float4 L2 = S( -1 , 1 , i.uv);
 float4 R2 = S( 1 , 1 , i.uv);
 float4 U2 = S( -1 , 1 , i.uv);
 float4 D2 = S( -1 , -1 , i.uv);

 float4 c1 = L + R + U + D;
 float4 c2 = L2 + R2 + U2 + D2;

 float4 t = -c * 6 + c1 + .5*c2;

 float4 dis = c - t;




 
 if( length(t.xyz)> 1){
  c.rgb = _BW * lerp(float3(1,1,1),c.rgb,_keepColor); 
 }else{
  c.rgb =  (1-_BW)* lerp(float3(1,1,1),c.rgb,_keepColor);//float3(1,1,1);
 }




 float4 result = c;
 if( c.r > .5 ){  result.a = .3; }

 //result.rgb = float3(1,1,1);//hsv( length(dis) * 10 , 1,length(dis) * .1);// + .1*c.rgb;//t.rgb;//lerp(c.rgb, bw, 1);
 return result;
 }
 ENDCG
 }
 }
}