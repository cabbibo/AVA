﻿Shader "Final/Wires" {
  Properties {
  
 		// This is how many steps the trace will take.
 		// Keep in mind that increasing this will increase
 		// Cost
    _NumberSteps( "Number Steps", Int ) = 3

    // Total Depth of the trace. Deeper means more parallax
    // but also less precision per step
    _TotalDepth( "Total Depth", Float ) = 0.16


    _NoiseSize( "Noise Size", Float ) = 10
    _HueSize( "Hue Size", Float ) = .3
    _BaseHue( "Base Hue", Float ) = .3

    _FadeMax( "Fade Max", float ) = 25
    _FadeMin( "Fade Min", float ) = 5

    _On ("On" , float ) = 0

  }

  SubShader {


    Pass {

      CGPROGRAM

      #pragma vertex vert
      #pragma fragment frag

      #include "UnityCG.cginc"


      uniform int _NumberSteps;
      uniform float _TotalDepth;
      uniform float _NoiseSize;
      uniform float _HueSize;
      uniform float _BaseHue;

      float _Cutoff;
      float _Hovered;
      float _On;


      struct VertexIn{
         float4 position  : POSITION; 
         float3 normal    : NORMAL; 
         float4 texcoord  : TEXCOORD0; 
         float4 tangent   : TANGENT;
      };


      struct VertexOut {
          float4 pos    	: POSITION; 
          float3 normal 	: NORMAL; 
          float4 uv     	: TEXCOORD0; 
          float3 ro     	: TEXCOORD1;
          float3 rd     	: TEXCOORD2;
          float3 player     	: TEXCOORD3;
      };


      float3 _Player;
      float _FadeMax;
      float _FadeMin;

			float3 hsv(float h, float s, float v){
        return lerp( float3( 1.0,1,1 ), clamp(( abs( frac(h + float3( 3.0, 2.0, 1.0 ) / 3.0 )
        					 * 6.0 - 3.0 ) - 1.0 ), 0.0, 1.0 ), s ) * v;
      }

       //From IQ shaders
      float hash( float n )
      {
          return frac(sin(n)*43758.5453);
      }

      float noise( float3 x )
      {
          // The noise function returns a value in the range -1.0f -> 1.0f

          float3 p = floor(x);
          float3 f = frac(x);

          f       = f*f*(3.0-2.0*f);
          float n = p.x + p.y*57.0 + 113.0*p.z;

          return lerp(lerp(lerp( hash(n+0.0), hash(n+1.0),f.x),
                         lerp( hash(n+57.0), hash(n+58.0),f.x),f.y),
                     lerp(lerp( hash(n+113.0), hash(n+114.0),f.x),
                         lerp( hash(n+170.0), hash(n+171.0),f.x),f.y),f.z);
      }


      float getFogVal(float3 rd, float3 pos ){

        float v = (noise( pos * 3 +_Time.y * .3) + .5 * noise( pos * 8 -_Time.y * .2) + .25 * noise( pos * 20 + _Time.y ) );
        return  v * v * v * .6 ;
      }
      

      
      VertexOut vert(VertexIn v) {
        
        VertexOut o;

        o.normal = v.normal;

        o.uv = v.texcoord;
       
  
        // Getting the position for actual position
        o.pos = UnityObjectToClipPos(  v.position );
     
        float3 mPos = mul( unity_ObjectToWorld , v.position );

        // The ray origin will be right where the position is of the surface
        o.ro = v.position;


        float3 camPos = mul( unity_WorldToObject , float4( _WorldSpaceCameraPos , 1. )).xyz;

        // the ray direction will use the position of the camera in local space, and 
        // draw a ray from the camera to the position shooting a ray through that point
        o.rd = normalize( v.position.xyz - camPos );

        o.player = v.position.xyz - mul( unity_WorldToObject , float4( _Player , 1. )).xyz;


        return o;

      }

      // Fragment Shader
      fixed4 frag(VertexOut v) : COLOR {




				// Ray origin 
        float3 ro 			= v.ro;

        // Ray direction
        float3 rd 			= v.rd;       

        // Our color starts off at zero,   
        float3 col = float3( 0.0 , 0.0 , 0.0 );



        float3 p;

        for( int i = 0; i < _NumberSteps; i++ ){


					float stepVal = float(i)/_NumberSteps;
        	// We get out position by adding the ray direction to the ray origin
        	// Keep in mind thtat because the ray direction is normalized, the depth
        	// into the step will be defined by our number of steps and total depth
          p = ro + rd * stepVal * _TotalDepth ;
  	
		
      float pDif = length(v.player - p);
      float fadeVal = 1-saturate((pDif - _FadeMin) / (_FadeMax-_FadeMin));


					// We get our value of how much of the volumetric material we have gone through
					// using the position
					float val = getFogVal(normalize(rd), p * _NoiseSize );	


          col += hsv( stepVal * _HueSize * (1 + _Hovered * .5 ) - _HueSize * .5* _Hovered + _BaseHue, 1 , val*val) * fadeVal;


        }

        //col *= col;
        
        col *= (1-_Cutoff);
        col *= ( 1 +_Hovered*2);

				col /= _NumberSteps;

				if( (1-v.uv.x) > _On ){ discard;}
		    fixed4 color;

		    col = float3(1,0,0);
        color = fixed4( col , 1. );
        return color;
      }

      ENDCG
    }
  }
  FallBack "Diffuse"
}
