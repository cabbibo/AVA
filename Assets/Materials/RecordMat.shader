Shader "Unlit/RecordMat"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry+20" }
        LOD 100
           
        Cull Off 
         ZTest Always
         ZWrite Off 

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = float4(1,1,1,1);//tex2D(_MainTex, i.uv);

                float2 uv = i.uv - float2(.5,.5);
                if( length( uv )> .48 ){
                    col = float4(0,0,0,1);
                }

                if( abs((atan2(uv.y, uv.x) - 1.5 + _Time.y * 3. ))%6.28 < .3 ){ col = float4(1,0,0,1);}

                if( length(uv) > .5 ){ discard; }
                // apply fog
               // UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
