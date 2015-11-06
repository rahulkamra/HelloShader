Shader "2D/DefaultSprite"
{
	Properties
	{
		_Color("Tint", Color) = (1,1,1,1)
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
			#pragma multi_compile _ PIXELSNAP_ON
			#include "UnityCG.cginc"

			//variables
			uniform sampler2D _MainTex;
			uniform fixed4 _Color;
			
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
			float _AlphaSplitEnabled;

			fixed4 SampleSpriteTexture(float2 uv)
			{
				fixed4 color = tex2D(_MainTex, uv);
				if (_AlphaSplitEnabled)
					color.a = tex2D(_AlphaTex, uv).r;

				return color;
			}
			//fragmen func
			fixed4 frag(v2f IN) : SV_Target
			{
				fixed4 c = SampleSpriteTexture(IN.texcoord) * IN.color;
			c.rgb *= c.a;
			return c;
			}

			ENDCG
		}
	}
}