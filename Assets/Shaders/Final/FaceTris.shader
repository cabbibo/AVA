Shader "Final/FaceTris" {
	Properties {
  	_Color ("Color", Color) = (1,1,1,1)
  	_Width ("_Width" , float) = .01
	}


  SubShader{

    Pass{

		  CGPROGRAM

		  #pragma target 4.5

		  #pragma vertex vert
		  #pragma fragment frag

		  #include "UnityCG.cginc"


      
		  #include "../Chunks/Struct12.cginc"


		  uniform int _Count;
		  uniform float3 _Color;
		  uniform float _Width;

		  uniform float4x4 _Transform;



      StructuredBuffer<Vert> _VertBuffer;
      StructuredBuffer<int> _TriBuffer;

      //A simple input struct for our pixel shader step containing a position.
      struct varyings {
          float4 pos : SV_POSITION;
      };

      //Our vertex function simply fetches a point from the buffer corresponding to the vertex index
      //which we transform with the view-projection matrix before passing to the pixel program.
      varyings vert (uint id : SV_VertexID){

        varyings o;
        

        int fID = id / 6;

        int idInTri = id%6;

        // Getting ID information
        int baseTri = fID / 3;
        int triID = fID % 3;
        int whichTri = triID;

        // Making sure we aren't looking up into a bad areas
        if( baseTri*3+whichTri < _Count ){

        	int t1 = _TriBuffer[baseTri*3+ ((whichTri+0)%3)];
        	int t2 = _TriBuffer[baseTri*3+ ((whichTri+1)%3)];


        	Vert v1 = _VertBuffer[t1];
        	Vert v2 = _VertBuffer[t2];

      		float3 pos;

      		float3 fp1 = mul(_Transform,float4(v1.pos-float3(0,0,-.002),1));
      		float3 fp2 = mul(_Transform,float4(v2.pos-float3(0,0,-.002),1));


      		float3 dir = fp1 - fp2;

      		fp1 += -dir * .3 * ( sin(v1.uv.x * 10 + v1.uv.y*10 + _Time.y) + 1);
      		fp2 -= -dir * .3 * ( sin(v2.uv.x * 10 + v2.uv.y*10 + _Time.y) + 1);


      		float3 x1 = normalize(cross(normalize(dir),fp1- _WorldSpaceCameraPos));
      		float3 x2 = normalize(cross(normalize(dir),fp2- _WorldSpaceCameraPos));

      		float3 p1 = fp1 - x1 * _Width;
      		float3 p2 = fp1 + x1 * _Width;
      		float3 p3 = fp2 - x2 * _Width;
      		float3 p4 = fp2 + x2 * _Width;


      		if( idInTri == 0 ){
      			pos = p1;
      		}else if( idInTri == 1 ){
      			pos = p2;
      		}else if( idInTri == 2 ){
      			pos = p4;
      		}else if( idInTri == 3 ){
      			pos = p1;
      		}else if( idInTri == 4 ){
      			pos = p4;
      		}else{
      			pos = p3;
      		}



	        o.pos = mul (UNITY_MATRIX_VP, float4(pos,1.0f));
	    
       	}

        return o;

      }

      //Pixel function returns a solid color for each point.
      float4 frag (varyings v) : COLOR {
          return float4( _Color , 1 );
      }

      ENDCG

    }
  }

  Fallback Off


}
