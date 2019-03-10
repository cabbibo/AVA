Shader "Final/LeafFace" {
  Properties {

        _CubeMap( "Cube Map" , Cube )  = "defaulttexture" {}

        _Color("_Color",Color)=(1,0,0,1)
        _Swap("_Swap",float)=0
        _NoiseSize("_NoiseSize",float)=0
        _NoiseSpeed("_NoiseSpeed",float)=0
        _Hue("_Hue",float)=0


       _ColorMap ("ColorMap", 2D) = "white" {}
       _NormalMap ("NormalMap", 2D) = "white" {}
    
  }

    SubShader {
        // COLOR PASS

        Pass {
            Tags{ "LightMode" = "ForwardBase" }
               LOD 150
            Blend Zero SrcColor
            ZWrite On

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
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 4.5
            #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight

      
        

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"


      #include "../Chunks/Struct16.cginc"
      
      #include "../Chunks/hsv.cginc"
      #include "../Chunks/noise.cginc"
            #include "../Chunks/safeID.cginc"


      #pragma vertex vert
            #pragma fragment frag
            

            samplerCUBE _CubeMap;

            float _Swap;
            float _Hue;
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
        float3 posddx = ddx(v.worldPos.xyz);
float3 posddy = ddy(v.worldPos.xyz);
float3 derivedNormal = cross( normalize(posddx), normalize(posddy) );

                fixed shadow = UNITY_SHADOW_ATTENUATION(v,v.worldPos );
                
                float4 nTex = tex2D(_NormalMap,1*v.uv) * 2 - 1;
    float3 n = derivedNormal;//  v.nor * nTex.y  + v.tan * nTex.x * 10+ v.bi * nTex.y*10;////normalize( normalize(float3( noise(v.worldPos*_NoiseSize) , noise(v.worldPos*_NoiseSize+10000) , noise(v.worldPos*_NoiseSize +100) -.5)) - 6*v.nor);
           // n = v.nor;//normalize(n);

            float3 refl = reflect( normalize( v.eye) , n);

                float3 fCol =refl;
                if( _Swap >=1 ){ fCol =refl.yzx; }
                if( _Swap >=2 ){ fCol =refl.zxy; }

                refl= fCol;


                float m = abs(dot( fCol, _WorldSpaceLightPos0.xyz ));

                float3 tCol =texCUBE(_CubeMap , refl );

float3 col;
                col =  .4*tCol * abs( refl * .3 + .7) * hsv( _Hue +v.uv.y * .3 ,.5,1);//lerp(tCol , tex2D(_ColorMap , float2(pow( m,4) * 4 + _Swap * .3,0)) , .6+pow(m,10));// * (fCol * .3 + .7);
        
            if( shadow > 0.99 ){discard;}
                //col = tCol;// normalize(n) * .5 + .5;//lerp(tex2D(_ColorMap , float2(pow( m,4) * .4 + _Swap * .3,0)) * pow(m,4) , tCol,1-m) ;// + tCol * (1-pow( m,20));// * _Color;// hsv( v.uv.x * .4 + v.debug.x * .4 + v.debug.y * 10 , .7,1);

                //col *= shadow*.5 + .2;
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



    }

}

