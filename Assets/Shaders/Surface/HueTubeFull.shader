  Shader "Post/HueTubeFull" {
    Properties {

      _MainTex ("Texture", 2D) = "white" {}
      _Amount ("Extrusion Amount", Range(-1,1)) = 0.5
      _Metallic ("Metallic", Range(0,1)) = 0.5
      _Smooth ("Smooth", Range(0,1)) = 0.5
       _BumpMap ("Bumpmap", 2D) = "bump" {}

    [Toggle(Enable16Struct)] _Struct16("16 Struct", Float) = 0
    [Toggle(Enable24Struct)] _Struct24("24 Struct", Float) = 0
    [Toggle(Enable36Struct)] _Struct36("36 Struct", Float) = 0
    }
    SubShader {
        Cull Off
      Tags { "RenderType" = "Opaque" }
      CGPROGRAM
         #pragma target 4.5
#include "UnityCG.cginc"
#include "../Chunks/hsv.cginc"
#include "../Chunks/StructIfDefs.cginc"
     #pragma vertex vert
      #pragma surface surf Standard addshadow
     
 				struct appdata{
            float4 vertex : POSITION;
            float3 normal : NORMAL;
            float4 tangent : TANGENT;
            float4 texcoord : TEXCOORD0;
            float4 texcoord1 : TEXCOORD1;
            float4 texcoord2 : TEXCOORD2;
 
            uint id : SV_VertexID;
         };
 
  

       struct Input {
          float2 texcoord1;
          float3 tangent;
          float3 normal;
          float2 debug;
      };


       float _Amount;

       #include "../Chunks/SetOutput.cginc"
 
 	sampler2D _MainTex;
 	sampler2D _BumpMap;
 	float _Metallic;
 	float _Smooth;
      void surf (Input IN, inout SurfaceOutputStandard o) {
         
          float3 mainCol = tex2D (_MainTex, IN.texcoord1.xy).rgb;
           o.Albedo = mainCol*3* hsv(IN.texcoord1.x * .2 + sin(IN.debug.x*1000) * .04 -.1,1,1);
        float3 nor = UnpackNormal(tex2D (_BumpMap, IN.texcoord1.xy * float2( 4.1, 1)));
        o.Metallic = _Metallic* IN.texcoord1.x;
        o.Smoothness = _Smooth* IN.texcoord1.x;
          o.Normal = nor;
      }
      ENDCG
    } 
   // Fallback "Diffuse"
  }
