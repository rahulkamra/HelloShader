﻿Shader "2D/Uncharted2ToneMapping"
{
	Properties
	{
		_Color("Tint",Color) = (1.0,1.0,1.0,1.0)
		_MainTex("Texture", 2D) = "white" {}
		_Exposure("Exposure",Range(0,10)) = 1
		_Gamma("Gamma",Range(0,10)) = 1
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
	uniform float _Gamma;



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

	float4 frag(vertexOut vo) : COLOR
	{
		float4 ft0 = tex2D(_MainTex, vo.uv);

		color *= _Exposure / (1. + color / _Exposure);
		color = pow(color, vec3(1. / _Gamma));
		return color;

		return ft0;
	}

		ENDCG
	}
	}
}
