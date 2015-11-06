Shader "2D/DefaultSprite"
{
	Properties
	{
		_Color("Tint",Color) = (1.0,1.0,1.0,1.0)
		_MainTex("MainTexture",2D) = "white"{}
	}
	SubShader
	{
		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
			"PreviewType" = "Plane"
			"CanUseSpriteAtlas" = "True"
		}

		Cull Off
		Lighting Off
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha


		Pass
		{
			CGPROGRAM

			//pragma
			#pragma vertex vert
			#pragma fragment frag
	
			//variables
			uniform sampler2D _MainTex;
			uniform float4 _Color;
			
			struct vertexIn
			{
				float4 vertex:POSITION;
				float2 uv:TEXCOORD0;
				float2 color:TEXCOORD0;
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
				float4 tex = tex2D(_MainTex, vo.uv) * _Color;
				return tex;
			}

			ENDCG
		}
	}
}