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
				float4 ft0 = tex2D(_MainTex, vo.uv);

				//exposure
				float4 ft1 = exp(ft0);
				ft1 = ft1 * float4(_Exposure, _Exposure, _Exposure, _Exposure);
				ft0 = ft0 * ft1;

				ft1.xyz = float3(_RedCoff, _GreenCoff, _BlueCoff);
				ft1.xyz = ft1.xyz * float3(0.299, 0.587, 0.114);
				ft1.w = 0;

				float4 ft2 = float4(0.0f, 0.0f, 0.0f, 0.0f);
				ft2.x = dot(ft0.xyz , ft1.xyz);
				ft2.yzw = ft2.xxx;

				// out * brightness
				ft2.xyz = ft2.xyz * _Brightness;
				
				// scale and bias (for maximum contrast)
				ft2.xyz = ft2.xyz + _Bias;
				ft2.xyz = max(ft2.xyz,0.0f);
				ft2.xyz = ft2.xyz * _Scale;

				ft2.w = ft0.w;
				return ft2;
			}

			ENDCG
		}
	}
}
