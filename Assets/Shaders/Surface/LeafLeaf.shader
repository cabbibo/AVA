Shader "Post/LeafLeaf" {
  Properties {

    _Color ("Color", Color) = (1,1,1,1)
    _HueStart("Hue Start",float) = 0
    _HueSize("Hue Size",float) = .2
    _HueOffset("Hue Offset",float) = .2
    _Saturation("Saturation",float) = .8

          _OutlineOut("OutlineOut", float) = .0004 
      _OutlineBack("OutlineBack", float) = .001
      _OutlineColor("OutlineColor", Color) = (1,1,1,1)
    
    [Toggle(Enable9Struct)]  _Struct9("9 Struct", Float) = 0
    [Toggle(Enable12Struct)] _Struct12("12 Struct", Float) = 0
    [Toggle(Enable16Struct)] _Struct16("16 Struct", Float) = 0
    [Toggle(Enable24Struct)] _Struct24("24 Struct", Float) = 0
    [Toggle(Enable36Struct)] _Struct36("36 Struct", Float) = 0
  }

	SubShader {
		// COLOR PASS

		Pass {
			Tags{ "LightMode" = "ForwardBase" }
			Cull Off

			CGPROGRAM
			#pragma target 4.5
		

			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
      
#pragma multi_compile Enable9Struct Enable12Struct Enable16Struct Enable24Struct Enable36Struct
    #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight

      #include "../Chunks/StructIfDefs.cginc"
      
      #include "../Chunks/hsv.cginc"
			#include "../Chunks/safeID.cginc"


      #pragma vertex vert
			#pragma fragment frag
			


			
      float3 _Color;
      float _HueSize;
      float _HueStart;
      float _HueOffset;
      float _Saturation;

      float3 _LightPos;
			struct varyings {
				float4 pos 		: SV_POSITION;
				float3 nor 		: TEXCOORD0;
				float2 uv  		: TEXCOORD1;
				float3 eye      : TEXCOORD5;
				float3 worldPos : TEXCOORD6;
				float3 debug    : TEXCOORD7;
				float3 closest    : TEXCOORD8;
				UNITY_SHADOW_COORDS(2)
			};

      int _TransferCount;

			varyings vert(uint id : SV_VertexID) {

        //id = safeID(id, _TransferCount);

				float3 fPos 	= _TransferBuffer[id].pos;
				float3 fNor 	= _TransferBuffer[id].nor;
        float2 fUV 		= _TransferBuffer[id].uv;
				float2 debug 	= _TransferBuffer[id].debug;

				varyings o;

				UNITY_INITIALIZE_OUTPUT(varyings, o);

				o.pos = mul(UNITY_MATRIX_VP, float4(fPos,1));
				o.worldPos = fPos;
				o.eye = _WorldSpaceCameraPos - fPos;
				o.nor = fNor;
				o.uv =  fUV;
				o.debug = float3(debug.x,0,0);

				UNITY_TRANSFER_SHADOW(o,o.worldPos);

				return o;
			}

			float4 frag(varyings v) : COLOR {
		
				fixed shadow = UNITY_SHADOW_ATTENUATION(v,v.worldPos -v.nor ) * .9 + .1 ;


			float3 x = ddx(v.worldPos);
				float3 yD = ddy(v.worldPos);

				float3 nor = -normalize(cross(x,yD));

				float3 lDir = normalize(v.worldPos - _LightPos);
				float3 refl = reflect( normalize(lDir) , nor );
				float m = pow(dot( normalize(v.eye) , refl ) ,2);// * _HueOffset;
				m *= 2;

				float m2 = - dot( lDir , nor );// * _HueOffset;
				//m2 *= 2;


				float3 col = hsv( m2 * _HueOffset  + length(v.worldPos - _LightPos) + v.uv.y * _HueSize + _HueStart , _Saturation,1 );// / length(v.worldPos - _LightPos); //float3( m , ;//hsv( m  + v.debug.x*_HueSize + _HueStart,_Saturation,1)* shadow;
				//col = refl * .5 + .5;
        return float4( col , 1.);
			}

			ENDCG
		}

  Cull Off
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

        //if( length( mainCol) < .5){discard;}
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

      #pragma fragmentoption ARB_precision_hint_fastest
      #include "UnityCG.cginc"

      #pragma multi_compile Enable9Struct Enable12Struct Enable16Struct Enable24Struct Enable36Struct
    

      #include "../Chunks/StructIfDefs.cginc"

      #pragma vertex vert
      #pragma fragment frag
      #pragma multi_compile_shadowcaster

      struct v2f {
        V2F_SHADOW_CASTER;
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
  


	}

}
