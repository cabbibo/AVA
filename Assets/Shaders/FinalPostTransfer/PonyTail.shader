Shader "Finals/PonyTail" {
  Properties {





        _OutlineExtrusion("Outline Extrusion", float) = 0
        _OutlineColor("Outline Color", Color) = (0, 0, 0, 1)

    
  }

    SubShader {
        // COLOR PASS

        Pass {
            Tags{ "LightMode" = "ForwardBase" }
            Cull Off


                        // Write to Stencil buffer (so that outline pass can read)
            Stencil
            {
                Ref 10
                Comp always
                Pass replace
                ZFail keep
            }

            CGPROGRAM
            #pragma target 4.5
        

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

    #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight

      #include "../Chunks/Struct16.cginc"
      
      #include "../Chunks/hsv.cginc"
      #include "../Chunks/noise.cginc"
            #include "../Chunks/safeID.cginc"


      #pragma vertex vert
            #pragma fragment frag
            

            samplerCUBE _CubeMap;

            float _Swap;
            float _NoiseSize;
            float _NoiseSpeed;

            float3 _Color;
            sampler2D _ColorMap;
            sampler2D _NormalMap;

      float3 _LightPos;
            struct varyings {
                float4 pos      : SV_POSITION;
                float3 nor      : TEXCOORD0;
                float2 uv       : TEXCOORD1;
                float3 bi      : TEXCOORD3;
                float3 tan      : TEXCOORD4;
                float3 eye      : TEXCOORD5;
                float3 worldPos : TEXCOORD6;
                float3 debug    : TEXCOORD7;
                float3 closest    : TEXCOORD8;
                UNITY_SHADOW_COORDS(2)
            };

      int _TransferCount;

            varyings vert(uint id : SV_VertexID) {

        //id = safeID(id, _TransferCount);

                float3 fPos     = _TransferBuffer[id].pos;
                float3 fNor     = _TransferBuffer[id].nor;
                float3 fTan     = _TransferBuffer[id].tan;
        float2 fUV      = _TransferBuffer[id].uv;
                float2 debug    = _TransferBuffer[id].debug;

                varyings o;

                UNITY_INITIALIZE_OUTPUT(varyings, o);

                o.pos = mul(UNITY_MATRIX_VP, float4(fPos,1));
                o.worldPos = fPos;
                o.eye = _WorldSpaceCameraPos - fPos;
                o.nor = normalize(fNor);
                o.uv =  fUV;
                o.tan = fTan;
                o.bi = normalize(cross(fTan,fNor));
                o.debug = float3(debug.x,debug.y,0);

                UNITY_TRANSFER_SHADOW(o,o.worldPos);

                return o;
            }

            float4 frag(varyings v) : COLOR {
        
                fixed shadow = UNITY_SHADOW_ATTENUATION(v,v.worldPos );
                


float3 col;
                col =   hsv(v.uv.x * .1 + sin(v.debug * .1) *.1 + .8 ,1,1);//3 * tCol * abs( refl * .3 + .7) * _Color;//lerp(tCol , tex2D(_ColorMap , float2(pow( m,4) * 4 + _Swap * .3,0)) , .6+pow(m,10));// * (fCol * .3 + .7);
       
                //col = tCol;// normalize(n) * .5 + .5;//lerp(tex2D(_ColorMap , float2(pow( m,4) * .4 + _Swap * .3,0)) * pow(m,4) , tCol,1-m) ;// + tCol * (1-pow( m,20));// * _Color;// hsv( v.uv.x * .4 + v.debug.x * .4 + v.debug.y * 10 , .7,1);

                col *= shadow*.5 + .5;
                return float4( col , 1.);
            }

            ENDCG
        }


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


      #include "../Chunks/Struct16.cginc"

      #pragma vertex vert
      #pragma fragment frag
      #pragma multi_compile_shadowcaster

      struct v2f {
        V2F_SHADOW_CASTER;
      };


      v2f vert(appdata_base v, uint id : SV_VertexID)
      {
        v2f o;


        float3 wPos = _TransferBuffer[id].pos;
        float3 wNor = _TransferBuffer[id].nor;

            // Default shadow caster pass: Apply the shadow bias.
    float scos = dot(wNor, normalize(UnityWorldSpaceLightDir(wPos)));
    wPos -= wNor * unity_LightShadowBias.z * sqrt(1 - scos * scos);
    o.pos = UnityApplyLinearShadowBias(UnityWorldToClipPos(float4(wPos, 1)));


        //o.pos = mul(UNITY_MATRIX_VP, float4(_TransferBuffer[id].pos + _TransferBuffer[id].nor * -.001, 1));
        return o;
      }

      float4 frag(v2f i) : COLOR
      {
        SHADOW_CASTER_FRAGMENT(i)
      }
      ENDCG
    }

            // Outline pass
        Pass
        {
            // Won't draw where it sees ref value 4
            Cull OFF
            ZWrite ON
            ZTest ON
            Stencil
            {
                Ref 10
                Comp notequal
                Fail keep
                Pass replace
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // Properties
            uniform float4 _OutlineColor;
            uniform float _OutlineSize;
            uniform float _OutlineExtrusion;
            uniform float _OutlineDot;

            struct vertexInput
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct vertexOutput
            {
                float4 pos : SV_POSITION;
                float4 color : COLOR;
            };

struct Vert{

      float3 pos;
      float3 vel;
      float3 nor;
      float3 tang;
      float2 uv;
    
      float2 debug;


    };      


    StructuredBuffer<Vert> _TransferBuffer;


              vertexOutput vert( uint id : SV_VertexID)
      {
                vertexOutput output;

                float3 newPos = _TransferBuffer[id].pos;

                // normal extrusion technique
                float3 normal = normalize(_TransferBuffer[id].nor);
                newPos += float4(normal, 0.0) * _OutlineExtrusion;

                // convert to world space
                output.pos = mul(UNITY_MATRIX_VP, float4(newPos, 1));

                output.color = _OutlineColor;
                return output;
            }

            float4 frag(vertexOutput input) : COLOR
            {
                // checker value will be negative for 4x4 blocks of pixels
                // in a checkerboard pattern
                //input.pos.xy = floor(input.pos.xy * _OutlineDot) * 0.5;
                //float checker = -frac(input.pos.r + input.pos.g);

                // clip HLSL instruction stops rendering a pixel if value is negative
                //clip(checker);

                return input.color;
            }

            ENDCG
        }



    }

}