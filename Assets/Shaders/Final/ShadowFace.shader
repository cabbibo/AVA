// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'


Shader "Final/ShadowFace"
{
	Properties
	{

		_Intensity("_Intensity", Range (0.0001, .9999))= .5

    
	}
  SubShader
  {
    // Regular color & lighting pass
    Pass
    {
      // shadows it
      Tags { "LightMode" = "ForwardBase" "RenderType"="Opaque" "Queue"="Geometry+1" "ForceNoShadowCasting"="True"  }
      LOD 150
      Blend Zero SrcColor
      ZWrite On


      CGPROGRAM
      #pragma vertex vert
      #pragma fragment frag
      #pragma target 4.5
        #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight

      #include "AutoLight.cginc"
      #include "UnityCG.cginc"
      #include "../Chunks/noise.cginc"
      #include "../Chunks/hsv.cginc"


      float _Intensity;

      #include "../Chunks/VertInput.cginc"

      
      float4 frag(vertexOutput v) : COLOR
      {
        //float attenuation = LIGHT_ATTENUATION(v); // shadow value
        float attenuation = UNITY_SHADOW_ATTENUATION(v,v.world  );
        float3 rgb = attenuation * _Intensity + ( 1-_Intensity);
        return saturate(float4(rgb, 1.0));
      }

      ENDCG
    }

// Shadow pass
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
      #include "../Chunks/Shadow16.cginc"

      ENDCG
    }

  }
}