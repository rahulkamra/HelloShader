Shader "2D/AnselTonMapping"
{
	Properties
	{
		_Color("Tint",Color) = (1.0,1.0,1.0,1.0)
		_MainTex ("Texture", 2D) = "white" {}
		_Exposure("Exposure",Range(0,5)) = 1
		_Brightness("Brightness",Range(0,5)) = 1
		_Scale("Scale",Range(0,10)) = 1
		_Bias("Bias",Range(0,1)) = 0
		_RedCoff("RedCoff",Range(0,2)) = 1
		_GreenCoff("GreenCoff",Range(0,2)) = 1
		_BlueCoff("BlueCoff",Range(0,2)) = 1
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
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"


			uniform sampler2D _MainTex;
			uniform float4 _Color;

			uniform float _Exposure;
			uniform float _Brightness;
			uniform float _Scale;
			uniform float _Bias;
			uniform float _RedCoff;
			uniform float _GreenCoff;
			uniform float _BlueCoff;

			struct vertexIn
			{
				float4 vertex:POSITION;
				float2 uv:TEXCOORD0;
				fixed4 color : COLOR;
			};

			struct vertexOut
			{
				float4 finalPos:SV_POSITION;
				float2 uv:TEXCOORD0;
				fixed4 color : COLOR;
			};

			//vertex func
			vertexOut vert(vertexIn vIn)
			{
				vertexOut vo;
				vo.finalPos = mul(UNITY_MATRIX_MVP, vIn.vertex);
				vo.uv = vIn.uv;
				vo.color = vIn.color * _Color;
				return vo;
			}
			
			float4 frag (vertexOut vo) : COLOR
			{
				float4 mainColor = tex2D(_MainTex, vo.uv);

				//exposure
				mainColor.xyz = float3(_Exposure, _Exposure, _Exposure)  * exp(mainColor) * mainColor;
				float3 colorCoff = float3(_RedCoff, _GreenCoff, _BlueCoff) * float3(0.299, 0.587, 0.114);

				float dotColor = dot(mainColor.xyz, colorCoff);

				// scale and bias (for maximum contrast)
				dotColor = dotColor * _Brightness + _Bias;
				dotColor = max(dotColor, 0.0f);
				dotColor = dotColor * _Scale;
				mainColor.xyz = dotColor;

				return mainColor;
			}

			ENDCG
		}
	}
}
