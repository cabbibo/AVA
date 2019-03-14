Shader "WireFrarm" { 
    Properties {
        _MainTex ("Font Texture", 2D) = "white" {}
        _Color ("Text Color", Color) = (1,1,1,1)
    }
 
    SubShader {
        
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha
        

       Pass{

      CGPROGRAM
      

       #pragma target 4.5

       #pragma vertex vert
       #pragma fragment frag


            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
       struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float id : TEXCOORD1;
                float3 bary : TEXCOORD2;
            };
      
      
      #include "UnityCG.cginc"
      #include "../Chunks/hsv.cginc"



      float4 _Color;
      sampler2D _MainTex;
      v2f vert (appdata_full v,uint vid : SV_VertexID){

          v2f o;

          o.vertex = UnityObjectToClipPos(v.vertex);
          o.uv = v.texcoord;//TRANSFORM_TEX(v.uv, _MainTex);
          o.id = floor( float(vid/3));//float(vid),0);//v.texcoord3;
          o.bary = float3(1,0,0);

          if( vid % 3 == 0 ){ o.bary = float3(1,0,0); }
          if( vid % 3 == 1 ){ o.bary = float3(0,1,0); }
          if( vid % 3 == 2 ){ o.bary = float3(0,0,1); }
          return o;
      
      }

       fixed4 frag (v2f i) : SV_Target{
                // sample the texture
                float3 col = 0;
                float v = fwidth(i.bary);

                float d = min(min(i.bary.x, i.bary.y), i.bary.z);
                if( d > .1 ){ col =1;}

                col = hsv( i.id * .1 , 1,1);
                //if( i.bary.y < .04 ){ col =1;}
                //if( i.bary.z < .04 ){ col =1;}
                //if( i.bary.y < .04 ||  ){ col =1;}
                //if( i.bary.z < .04 ||  ){ col =1;}
                fixed4 color = float4(col,1);// * _Color * float4(1,1,1,tex2D(_MainTex, i.uv).a);
                return color;
            }
      ENDCG
  }
    }
}