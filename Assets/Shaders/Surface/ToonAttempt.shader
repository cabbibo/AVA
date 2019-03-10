  Shader "Post/Toon" {
    Properties {

      _MainTex ("Texture", 2D) = "white" {}
      _Amount ("Extrusion Amount", Range(-1,1)) = 0.5
      _Metallic ("Metallic", Range(0,1)) = 0.5
      _Smooth ("Smooth", Range(0,1)) = 0.5
      _Threshold ("Thresh", Range(0,20)) = 6
      _HueSize("HueSize", float) = .5
      _HueStart("HueStart", float) = .5
      _Saturation("Saturation", float) = .8
      _Fade("Fade", float) = .2
       _BumpMap ("Bumpmap", 2D) = "bump" {}

      _OutlineOut("OutlineOut", float) = .0004 
      _OutlineBack("OutlineBack", float) = .001
      _OutlineColor("OutlineColor", Color) = (1,1,1,1)

    [Toggle(Enable12Struct)] _Struct12("12 Struct", Float) = 0
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


			#pragma multi_compile  Enable12Struct Enable16Struct Enable24Struct Enable36Struct
      #include "../Chunks/StructIfDefs.cginc"





      #pragma vertex vert
      #pragma surface surf Standard addshadow
      sampler2D _MainTex;
      sampler2D _BumpMap;
      float _Metallic;
      float _Smooth;
       float _Amount;
       float _Threshold;
       float _HueSize;
       float _HueStart;
       float _Saturation;
       float _Fade;


       
     
        struct appdata{
            float4 vertex : POSITION;
            float3 normal : NORMAL;
            float4 tangent : TANGENT;
            float4 texcoord : TEXCOORD0;
            float4 texcoord1 : TEXCOORD1;
            float4 texcoord2 : TEXCOORD2;
            uint id : SV_VertexID;
         };
 
  

   


      float LightToonShading(float3 normal, float3 lightDir)
            {
                float NdotL = max(0.0, dot(normalize(normal), normalize(lightDir)));
                return floor(NdotL * _Threshold) / (_Threshold - 0.5);
            }



      #include "../Chunks/SetOutput.cginc"

      void surf (Input v, inout SurfaceOutputStandard o) {
         
        float3 mainCol = tex2D (_MainTex, v.texcoord1.xy).rgb;

        //if( length( mainCol) < .5){discard;}
        //mainCol;//*3* hsv(v.texcoord1.x * .2 + sin(v.debug.x*1000) * .04 -.1,1,1);
      	float3 nor = UnpackNormal(tex2D (_BumpMap, v.texcoord1.xy ));
      	float toon = LightToonShading(v.normal,_WorldSpaceLightPos0.xyz);


      	float3 col = hsv( toon * _HueSize + _HueStart,_Saturation,1-_Fade *(1-toon));
      	//if( -dot(normalize(v.eye) , v.normal) < .4 ){ col = float3(1,1,0); }

       	o.Albedo = nor * .5 + .5;//col;
      	o.Metallic = _Metallic;
      	o.Smoothness = _Smooth;
        o.Normal = -v.normal;//nor;
      }
      ENDCG


      

      CGPROGRAM
      
      #pragma target 4.5
      #include "UnityCG.cginc"
      #include "../Chunks/hsv.cginc"


      #pragma multi_compile  Enable12Struct Enable16Struct Enable24Struct Enable36Struct
      #include "../Chunks/StructIfDefs.cginc"





      #pragma vertex vert
      #pragma surface surf NoLighting
      sampler2D _MainTex;
      sampler2D _BumpMap;
      float _Metallic;
      float _Smooth;
       float _Amount;
       float _Threshold;
       float _HueSize;
       float _HueStart;
       float _Saturation;
       float _Fade;


       
     
        struct appdata{
            float4 vertex : POSITION;
            float3 normal : NORMAL;
            float4 tangent : TANGENT;
            float4 texcoord : TEXCOORD0;
            float4 texcoord1 : TEXCOORD1;
            float4 texcoord2 : TEXCOORD2;
            uint id : SV_VertexID;
         };
 
  

   


      float LightToonShading(float3 normal, float3 lightDir)
            {
                float NdotL = max(0.0, dot(normalize(normal), normalize(lightDir)));
                return floor(NdotL * _Threshold) / (_Threshold - 0.5);
            }



      
        struct varyings {
          float2 texcoord1;
          float3 tangent;
          float3 normal;
          float3 worldPos;
          float3 eye;
          float2 debug;
      };

        struct Input {
          float2 texcoord1;
          float3 tangent;
          float3 normal;
          float3 worldPos;
          float3 eye;
          float2 debug;
      };

             float _OutlineOut;
       float _OutlineBack;
       float3 _OutlineColor;
       void vert (inout appdata v, out Input data ) {
      
        UNITY_INITIALIZE_OUTPUT( Input , data );
        #if defined(SHADER_API_METAL) || defined(SHADER_API_D3D11)
            float3 fPos =_TransferBuffer[v.id].pos;
            float3 fNor =_TransferBuffer[v.id].nor;
            float3 fTan =_TransferBuffer[v.id].tan;
            float2 fUV =_TransferBuffer[v.id].uv;
          
                v.vertex = float4(fPos,1) + float4(fNor,0) * _OutlineOut + float4( normalize( fPos - _WorldSpaceCameraPos ) *_OutlineBack,0);// float4(v.vertex.xyz,1.0f);
                v.normal = fNor; //float4(normalize(points[id].normal), 1.0f);
                v.tangent = float4(0,1,0,1);//float4(fTan,1);//float4( normalize(cross(fNor,float3(0,1,0))),1);
                 //v.UV = fUV;
               // v.texcoord1 = fUV;
                data.texcoord1 = fUV;//float2(1,1);
                data.tangent =fTan;
                data.normal =fNor;
                data.eye = fPos - _WorldSpaceCameraPos;
                data.worldPos = fPos;
                data.debug =  _TransferBuffer[v.id].debug;
            #endif
  
         }
 

      void surf (Input v, inout SurfaceOutput o) {
         
        float3 mainCol = tex2D (_MainTex, v.texcoord1.xy).rgb;

        if( length( mainCol) < .5){discard;}
        //mainCol;//*3* hsv(v.texcoord1.x * .2 + sin(v.debug.x*1000) * .04 -.1,1,1);
        float3 nor = UnpackNormal(tex2D (_BumpMap, v.texcoord1.xy ));
        float toon = LightToonShading(v.normal,_WorldSpaceLightPos0.xyz);


        float3 col = hsv( toon * _HueSize + _HueStart,_Saturation,1-_Fade *(1-toon));
        //if( -dot(normalize(v.eye) , v.normal) < .4 ){ col = float3(1,1,0); }

        o.Albedo = float4(0,0,0,1);
        o.Normal = -v.normal;//nor;
      }

      fixed4 LightingNoLighting(SurfaceOutput s, fixed3 lightDir, fixed atten) {
         return fixed4(_OutlineColor,1);//half4(s.Albedo, s.Alpha);
     }
      ENDCG
    } 

   // Fallback "Diffuse"
  }
