// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "UnityFinals/ImmatBG"
{

      Properties {

        _CubeMap( "Cube Map" , Cube )  = "defaulttexture" {}

       _BumpMap ("_BumpMap", 2D) = "white" {}

    
  }
    SubShader
    {
        Pass
        {

            Cull Front
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            #include "../Chunks/noise.cginc"


            sampler2D _BumpMap;
            samplerCUBE _CubeMap;

           struct v2f {
                float3 worldPos : TEXCOORD0;
                // these three vectors will hold a 3x3 rotation matrix
                // that transforms from tangent to world space
                half3 tspace0 : TEXCOORD1; // tangent.x, bitangent.x, normal.x
                half3 tspace1 : TEXCOORD2; // tangent.y, bitangent.y, normal.y
                half3 tspace2 : TEXCOORD3; // tangent.z, bitangent.z, normal.z
                // texture coordinate for the normal map
                float2 uv : TEXCOORD4;
                float4 pos : SV_POSITION;
            };


            v2f vert (float4 vertex : POSITION, float3 normal : NORMAL, float4 tangent : TANGENT, float2 uv : TEXCOORD0)
            {
                v2f o;

                float n = noise( vertex * 100 + float3(_Time.y,_Time.y * .4,0));//sin(vertex.x * 100 + _Time * 10 ) + sin( vertex.y * 100 +  _Time * 10 );

                float3 fPos = vertex - normal * n * .4;
                o.pos = UnityObjectToClipPos(float4(fPos,1));
                o.worldPos = mul(unity_ObjectToWorld, float4(fPos,1)).xyz;
                o.uv = uv;
                return o;
            }
            fixed4 frag (v2f i) : SV_Target
            {


                float3 dx = ddx( i.worldPos );
                float3 dy = ddy(i.worldPos );

                float3 worldNormal = normalize(cross(dx,dy));
               
                /*half3 tnormal = UnpackNormal(tex2D(_BumpMap, i.uv+ float2(_Time.y * .01,0)) * .5);
                 tnormal += UnpackNormal(tex2D(_BumpMap, i.uv - float2(_Time.y * .01,0)) * .5);

                // transform normal from tangent to world space
                half3 worldNormal;
                worldNormal.x = dot(i.tspace0, tnormal);
                worldNormal.y = dot(i.tspace1, tnormal);
                worldNormal.z = dot(i.tspace2, tnormal);*/

                // rest the same as in previous shader
                half3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                half3 worldRefl =refract(-worldViewDir, worldNormal,.7);


                // sample the default reflection cubemap, using the reflection vector
                //half4 skyData = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, i.worldRefl);
                // decode cubemap data into actual color
                half3 skyColor = texCUBE(_CubeMap  , worldRefl );//DecodeHDR (skyData, unity_SpecCube0_HDR);
                // output it!
                fixed4 c = 0;
                c.rgb = skyColor * .3 *  (worldNormal * .5 + .5);//skyColor;
                return c;
            }
            ENDCG
        }
    }
}
