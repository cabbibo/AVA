Shader "Finals/Text" { 
    Properties {
        _MainTex ("Font Texture", 2D) = "white" {}
        _Color ("Text Color", Color) = (1,1,1,1)
    }
 
    SubShader {
        Tags { "Queue" = "Overlay" "IgnoreProjector"="True" "RenderType"="Transparent" }
        


ZTest Always
Lighting Off Cull Off Fog { Mode Off }
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
            };
      
      
      #include "UnityCG.cginc"
      #include "../Chunks/hsv.cginc"



      float4 _Color;
      sampler2D _MainTex;

      float _CurrentLetter;
      v2f vert (appdata_full v,uint vid : SV_VertexID){

          v2f o;
          o.vertex = UnityObjectToClipPos(v.vertex);
          o.uv = v.texcoord;//TRANSFORM_TEX(v.uv, _MainTex);
          o.id = floor( float(vid/4));//float(vid),0);//v.texcoord3;
          return o;
      
      }

       fixed4 frag (v2f i) : SV_Target{
                // sample the texture
                fixed4 color = _Color;//float4( 0,1,0,1);

                if( i.id != _CurrentLetter ){ color *=  float4(1,1,1,tex2D(_MainTex, i.uv).a); }else{
                    color.a  *= abs(sin(_Time * 300 + i.id));
                }

                if( i.id > _CurrentLetter ){ color = float4(0,0,0,0); }
                
                return color;
            }
      ENDCG
  }
    }
}