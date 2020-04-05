// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'


Shader "Debug/Body"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
    
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

  

            CGPROGRAM
            #pragma target 4.5
      #pragma vertex vert
      #pragma fragment frag

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
    
      float used;
    
     
      float3 targetPos;
      float3 bindPos;
      float3 bindNor;
      float3 bindTan;

      float4 boneWeights;
      float4 boneIDs;

      float debug;

    };

    StructuredBuffer<Vert> _TransferBuffer;

         struct vertexOutput
      {
          float4 pos : SV_POSITION;
          float3 normal : NORMAL;
          float2 uv: TEXCOORD0;
          float3 world : TEXCOORD1;
      };

    
            vertexOutput vert(uint id : SV_VertexID) {
            


                
                
                vertexOutput output;

UNITY_INITIALIZE_OUTPUT(vertexOutput, output);
                Vert input = _TransferBuffer[id];

                // convert input to world space
                output.pos = mul(UNITY_MATRIX_VP, float4(input.pos,1));
                float4 normal4 = float4(input.nor, 0.0); // need float4 to mult with 4x4 matrix
                output.normal = input.nor;//normalize(mul(normal4, unity_WorldToObject).xyz);
               output.world = input.pos;// mul(unity_ObjectToWorld, input.vertex).xyz;
            output.uv = input.uv;

                //TRANSFER_VERTEX_TO_FRAGMENT(output); // shadows
                return output;
            }

            float4 frag(vertexOutput v) : COLOR
            {

        float4 col = _Color; 

  
                return float4(col.xyz, 1.0);
            }

            ENDCG
        }
    }
}