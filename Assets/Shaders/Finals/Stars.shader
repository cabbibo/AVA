Shader "Final/Stars" {
  Properties {

    _Color ("Color", Color) = (1,1,1,1)
    
    _CubeMap( "Cube Map" , Cube )  = "defaulttexture" {}
    

       _ColorMap ("ColorMap", 2D) = "white" {}
       _SpriteMap ("SpriteMap", 2D) = "white" {}
    
  }

	SubShader {
		// COLOR PASS

		Pass {
			Tags{ "LightMode" = "ForwardBase" }
			Cull Off

			CGPROGRAM
			#pragma target 4.5
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"    

			struct Vert{
    	  float3 pos;
    	  float3 vel;
    	  float3 nor;
    	  float3 tan;
    	  float2 uv;
    	  float2 debug;
    	};

    	StructuredBuffer<Vert> _TransferBuffer;
      uniform sampler2D _ColorMap;
      uniform sampler2D _SpriteMap;
      samplerCUBE _CubeMap;

      float3 _Color;

      float3 _Player;


			struct varyings {
				float4 pos 		: SV_POSITION;
				float3 nor 		: TEXCOORD0;
				float2 uv  		: TEXCOORD1;
				float3 eye      : TEXCOORD5;
				float3 worldPos : TEXCOORD6;
				float3 debug    : TEXCOORD7;
        float3 closest    : TEXCOORD8;
        float3 tan   : TEXCOORD9;
        float3 vel   : TEXCOORD10;
				float2 sprite   : TEXCOORD11;
				UNITY_SHADOW_COORDS(2)
			};

      #include "../Chunks/hsv.cginc"
			#include "../Chunks/noise.cginc"

			varyings vert(uint id : SV_VertexID) {

				float3 fPos 	= _TransferBuffer[id].pos;
				float3 fNor 	= _TransferBuffer[id].nor;
        float2 fUV 		= _TransferBuffer[id].uv;
        float2 debug  = _TransferBuffer[id].debug;
        float3 fTan   = _TransferBuffer[id].tan;
				float3 fVel 	= _TransferBuffer[id].vel;

				varyings o;

				UNITY_INITIALIZE_OUTPUT(varyings, o);

				o.pos = mul(UNITY_MATRIX_VP, float4(fPos,1));
				o.worldPos = fPos;
				o.eye = _WorldSpaceCameraPos - fPos;
				o.nor = fNor;
				o.uv =  fUV;
        o.sprite = debug;//fUV * (1./6.)+ floor(float2(hash(debug.x*10), hash(debug.x*20)) * 6)/6;
      
        o.tan = fTan;
        o.vel = fVel;
				o.debug = float3(debug.x,debug.y,0);

				UNITY_TRANSFER_SHADOW(o,o.worldPos);

				return o;
			}

			float4 frag(varyings v) : COLOR {
		
				fixed shadow = UNITY_SHADOW_ATTENUATION(v,v.worldPos) * .9 + .1 ;
				float4 d = tex2D(_SpriteMap,v.debug);
      //  if( length(d.xyz) > 1 ){discard;}

        float n = noise(v.worldPos * 10);
        float3 fNor = normalize(v.nor + v.tan * 10  * (sin(10*v.uv.y  - 3*_Time.y)+3*n));
        
        float3 lDir = _Player - v.worldPos;
        float pDist = length(lDir);
        lDir = normalize(lDir);
        float3 refl = reflect( lDir , fNor );
        float rM  = dot( normalize( v.eye) , refl );

float3 refl2 = reflect( normalize(v.eye), fNor);
float3 tCol =   texCUBE(_CubeMap , refl2 );// * (fNor * .3 + .89);

  float eM = dot( normalize(v.eye),fNor);
        float3 col = normalize(lDir) * .5 + .5;

        eM *= eM;
        //rM = rM*rM*rM*rM*rM;
        float3 iri = tex2D(_ColorMap,float2( pDist * .1+ eM * .6 + length(v.vel * 30),0)).xyz;
        //float3 iri = tex2D(_ColorMap,float2( length(tCol)  + length(v.vel * 10),0)).xyz;
        
        float3 falloff = 1.4*saturate(50/ (pDist*pDist));
         col = tCol * (.5 + .5*iri*eM);//((tCol*length(iri)) + iri) * falloff;//( .5 + .5*tex2D(_ColorMap,float2( eyeMatch * .5 + pDist  * .04 - .2*_Time.y ,0))* saturate(10/ (pDist*pDist*pDist)));// * rM;//hsv(v.uv.y,1,rM);// + normalize(refl) * .5+.5;
        
         if( (v.uv.y + n * .2) > .95 ){ col= tCol * hsv(length(tCol) * .1,1,1);}//-col;}
        if( (v.uv.y + n * .2) > 1.1 ){ discard; }
         col *= falloff*falloff;
        return float4(  col * shadow, 1.);
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
#include "../Chunks/StructIfDefs.cginc"

sampler2D _MainTex;
  struct v2f {
        V2F_SHADOW_CASTER;
        float2 uv : TEXCOORD1;
      };


      v2f vert(appdata_base v, uint id : SV_VertexID)
      {
        v2f o;
       
        o.uv =  float2(.9,1)- _TransferBuffer[id].uv;
        o.pos = mul(UNITY_MATRIX_VP, float4(_TransferBuffer[id].pos, 1));
        return o;
      }

      float4 frag(v2f i) : COLOR
      {
        //float4 col = tex2D(_MainTex,i.uv);
       // if( col.a < .4){discard;}
        SHADOW_CASTER_FRAGMENT(i)
      }
      ENDCG
    }
  


	}

}
