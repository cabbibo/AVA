
Shader "Finals/Glitch" {
 Properties {
 _MainTex ("Base (RGB)", 2D) = "white" {}
 }
 SubShader {
 Pass {
 CGPROGRAM
 #pragma vertex vert_img
 #pragma fragment frag
 
 #include "UnityCG.cginc"
 #include "../Chunks/noise.cginc"
 
 uniform sampler2D _MainTex;

 float _GlitchPower;
 float _UpDown;
 float _SwipeVal;
 
 float4 frag(v2f_img i) : COLOR {



    float block_threshR = pow(frac(_Time.y * 1238.0453), 2.0) * 1;
    float block_threshG = pow(frac(_Time.y * 1538.0453), 2.0) * 1;
    float block_threshB = pow(frac(_Time.y * 1938.0453), 2.0) * 1;


    float bander = i.uv.x;
    if( _UpDown == 0){
        bander = i.uv.y;
    }

    float fSwipeVal = 1;
    if( _SwipeVal < 0 ){ fSwipeVal = 0; }

    float noiseR = abs(noise( float3( floor(hash( bander * .00001 + (fSwipeVal-.5)*_Time * .001) * 20 ) + floor(hash( bander * .000033 + (fSwipeVal-.5)*_Time.y * .00001) * 20 ), 1, frac((fSwipeVal-.5)*_Time.y * 20))));
    float noiseG = abs(noise( float3( floor(hash( bander * .000015 + (fSwipeVal-.5)*_Time * .001 + .3) * 23 ) + floor(hash( bander * .000037+ 3. + (fSwipeVal-.5)*_Time.y * .00001) * 19 ), 1, frac((fSwipeVal-.5)*_Time.y * 20))));
    float noiseB = abs(noise( float3( floor(hash( bander * .000013 + (fSwipeVal-.5)*_Time * .001 + 1.3) * 29 ) + floor(hash( bander * .000033+ 9. + (fSwipeVal-.5)*_Time.y * .00001) * 18 ), 1, frac((fSwipeVal-.5)*_Time.y * 20))));
   // if( sin(i.uv.y * 20.) < block_threshR && sin(i.uv.y * 10.) > block_threshR - _GlitchPower*2 ){ uvR = float2(uvR.x + .2*sin(floor(uvR.y * 10)) * _GlitchPower,uvR.y); }
   // if( sin(i.uv.y * 20.) < block_threshG && sin(i.uv.y * 10.) > block_threshG - _GlitchPower*2 ){ uvG = float2(uvG.x + .2*sin(floor(uvR.y * 10)) * _GlitchPower,uvG.y); }
   // if( sin(i.uv.y * 20.) < block_threshB && sin(i.uv.y * 10.) > block_threshB - _GlitchPower*2 ){ uvB = float2(uvB.x + .2*sin(floor(uvR.y * 10)) * _GlitchPower,uvB.y); }

   fSwipeVal = -fSwipeVal + 1;

    float3 fCol;// = float3( tex2D( _MainTex , uvR ).r , tex2D( _MainTex , uvG ).g , tex2D( _MainTex , uvB ).b );
    float fR = 2* (noiseR+.3) * ( fSwipeVal -.5) * _GlitchPower * _GlitchPower * _GlitchPower * .1;
    float fG = 2* (noiseG+.3) * ( fSwipeVal -.5) * _GlitchPower * _GlitchPower * _GlitchPower * .1;
    float fB = 2* (noiseB+.3) * ( fSwipeVal -.5) * _GlitchPower * _GlitchPower * _GlitchPower * .1;
    float fColX = tex2D(_MainTex , i.uv + float2( fR  *(1-_UpDown) , fR  * (_UpDown) ) ).x;
    float fColY = tex2D(_MainTex , i.uv + float2( fG  *(1-_UpDown) , fG  * (_UpDown) ) ).y;
    float fColZ = tex2D(_MainTex , i.uv + float2( fB  *(1-_UpDown) , fB  * (_UpDown) ) ).z;
    return float4(fColX, fColY, fColZ ,1);
 }
 ENDCG
 }
 }
}