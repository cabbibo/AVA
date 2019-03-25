// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'


Shader "Finals/OKToCry"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _ColorMap("Ramp", 2D) = "white" {}
        _Color("Color", Color) = (1, 1, 1, 1)
        _OutlineExtrusion("Outline Extrusion", float) = 0
        _OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
        _RampStart("Start", float)= 0
        _CubeMap( "Cube Map" , Cube )  = "defaulttexture" {}
    
    }

    SubShader
    {
        // Regular color & lighting pass
        Pass
        {
            Tags
            { 
                "LightMode" = "ForwardBase" // allows shadow rec/cast
            }

            Cull Off
            // Write to Stencil buffer (so that outline pass can read)
            Stencil
            {
                Ref 4
                Comp always
                Pass replace
                ZFail keep
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase // shadows
            #include "AutoLight.cginc"
            #include "UnityCG.cginc"
      #include "../Chunks/noise.cginc"
            #include "../Chunks/hsv.cginc"

            // Properties
            sampler2D _MainTex;
            sampler2D _ColorMap;  
             samplerCUBE _CubeMap;
            float4 _Color;
            float4 _LightColor0; // provided by Unity

            float _RampSize;
            float _RampStart;
    

        
struct Vert{

      float3 pos;
      float3 vel;
      float3 nor;
      float3 tang;
      float2 uv;
    
      float2 debug;


    };  

    float _HueSize;
    float _HueStart;
    float _HueRandomness;
    float _SparkleHue;
    float _SparkleBright;

  StructuredBuffer<Vert> _TransferBuffer;


            struct vertexOutput
            {
                float4 pos : SV_POSITION;
                float3 normal : NORMAL;
                float2 uv: TEXCOORD0;
                float3 world : TEXCOORD3;
        float3 tan : TEXCOORD4;
                float3 vel : TEXCOORD5;
                LIGHTING_COORDS(1,2) // shadows
            };

    
            vertexOutput vert(uint id : SV_VertexID) {
            


                vertexOutput output;
                Vert input = _TransferBuffer[id];

                // convert input to world space
                output.pos = mul(UNITY_MATRIX_VP, float4(input.pos,1));
                float4 normal4 = float4(input.nor, 0.0); // need float4 to mult with 4x4 matrix
                output.normal = input.nor;//normalize(mul(normal4, unity_WorldToObject).xyz);
                output.tan = input.tang;//.w * normalize(mul(input.tan, unity_WorldToObject).xyz);
                output.world = input.pos;// mul(unity_ObjectToWorld, input.vertex).xyz;
                output.vel = input.vel;
                output.uv = input.uv;




                float2 uvVals = input.uv - float2( .5 , .2 ); 
                float mult = .8;

                float3 up = normalize(cross(input.nor, input.tang ));
                float3 fNor = UNITY_MATRIX_IT_MV[2].xyz + mult*input.tang.xyz * uvVals.x + mult*up * uvVals.y;//;normalize(v.vel);//normalize(cross(dx,dy));//v.normal;//normalize(v.normal + noise(float3( v.texCoord.xy * 100  + float2(_Time.y * 1.4 , _Time.y * 2), _Time.y )) * v.tan);
             
                output.normal = fNor;

                TRANSFER_VERTEX_TO_FRAGMENT(output); // shadows
                return output;
            }

            float4 frag(vertexOutput v) : COLOR
            {
                // lighting mode

     

                //float2 uvVals = v.uv - float2( .5 , .7 ); 
                //float mult = .8;
                //float3 fNor = UNITY_MATRIX_IT_MV[2].xyz + mult*UNITY_MATRIX_IT_MV[0].xyz * uvVals.x + mult*UNITY_MATRIX_IT_MV[1].xyz * uvVals.y;//;normalize(v.vel);//normalize(cross(dx,dy));//v.normal;//normalize(v.normal + noise(float3( v.texCoord.xy * 100  + float2(_Time.y * 1.4 , _Time.y * 2), _Time.y )) * v.tan);
                
                float3 fNor = v.normal;//normalize( fNor );
                float3 eye = _WorldSpaceCameraPos - v.world;

                float3 bgCol = float3(
                                  texCUBE( _CubeMap , refract( -normalize(eye) , -fNor , 1)).r,
                                  texCUBE( _CubeMap , refract( -normalize(eye) , -fNor , .6)).g,
                                  texCUBE( _CubeMap , refract( -normalize(eye) , -fNor , .2)).b
                                );


                                // convert light direction to world space & normalize
                // _WorldSpaceLightPos0 provided by Unity
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                float attenuation = LIGHT_ATTENUATION(v); // shadow value
                float3 rgb;// = lighting*attenuation*ramp;//lbedo.rgb * _LightColor0.rgb * lighting * _Color.rgb * attenuation;
               float4 tCol = tex2D(_MainTex ,v.uv);//float3(tColR.r,tColG.g , tColB.b);

               float3 col = tCol.xyz;// * hsv( dot(normalize(v.vel),float3(0,1,0)) * 1,1,1) * 2.;//*100;
               col = bgCol;
               if( tCol.x > .3 ){ discard; }

        fixed shadow = UNITY_SHADOW_ATTENUATION(v,v.world) * .9 + .1 ;

     

     


                return float4(col  * shadow, 1.0);
            }

            ENDCG
        }


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
      #pragma vertex vert
      #pragma fragment frag
      #pragma multi_compile_shadowcaster
      #pragma fragmentoption ARB_precision_hint_fastest

  #include "UnityCG.cginc"

struct Vert{

      float3 pos;
      float3 vel;
      float3 nor;
      float3 tang;
      float2 uv;
    
      float2 debug;


    };  


        StructuredBuffer<Vert> _TransferBuffer;


sampler2D _MainTex;
  struct v2f {
        V2F_SHADOW_CASTER;
        float2 uv : TEXCOORD1;
      };


      v2f vert(appdata_base v, uint id : SV_VertexID)
      {
        v2f o;
        o.pos = mul(UNITY_MATRIX_VP, float4(_TransferBuffer[id].pos, 1));
        o.uv = _TransferBuffer[id].uv;
        return o;
      }

      float4 frag(v2f i) : COLOR
      {
        float4 tCol = tex2D(_MainTex ,i.uv);//float3(tColR.r,tColG.g , tColB.b);

        if( tCol.x > .3 ){ discard; }

        SHADOW_CASTER_FRAGMENT(i)
      }
      ENDCG
    }

  }
  

}
