Shader "2D/DefaultSprite"
{
	Properties
	{
		_MulColor("MulColor",Color) = (1.0,1.0,1.0,1.0)
		_AddColor("AddColor",Color) = (0.0,0.0,0.0,0.0)
		_MainTex("MainTexture",2D) = "white"{}
	}
	SubShader
	{
		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}
		Blend SrcAlpha OneMinusSrcAlpha
		AlphaTest GEqual 0.1

		Pass
		{
			CGPROGRAM

			//pragma
			#pragma vertex vert
			#pragma fragment frag

			//variables
			uniform sampler2D _MainTex;
			uniform float4 _MulColor;
			uniform float4 _AddColor;
			
			struct vertexIn
			{
				float4 vertex:POSITION;
				float2 uv:TEXCOORD0;
			};

			struct vertexOut
			{
				float4 finalPos:SV_POSITION;
				float2 uv:TEXCOORD0;
			};



			//vertex func
			vertexOut vert(vertexIn vIn)
			{
				vertexOut vo;
				vo.finalPos = mul(UNITY_MATRIX_MVP , vIn.vertex);
				vo.uv = vIn.uv;
				return vo;
			}

			//fragmen func
			float4 frag(vertexOut vo) : COLOR
			{
				float4 tex = tex2D(_MainTex, vo.uv) * _MulColor;
				tex.a = 0.1;
				return tex;
			}

			ENDCG
		}
	}
}