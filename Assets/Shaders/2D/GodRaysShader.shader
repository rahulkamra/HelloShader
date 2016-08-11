Shader "2D/GodRaysShader"
{
	Properties
	{
		_Color("Tint",Color) = (1.0,1.0,1.0,1.0)
		_MainTex("MainTexture",2D) = "white"{}
		_Density("Density",Range(0,1)) = 0.2
		_Samples("Samples",Range(0,100)) = 16
		_Weight("Weight",Range(0,5)) = 1
		_Decay("Decay",Range(0,5)) = 1.05
		_LightX("LightX",Range(0,1)) = 0.5
		_LightY("LightY",Range(0,1)) = 0.5

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
	uniform float _Density;
	uniform int _Samples;
	uniform float _Weight;
	uniform float _Decay;
	uniform float _LightX;
	uniform float _LightY;
	
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
		vo.finalPos = mul(UNITY_MATRIX_MVP , vIn.vertex);
		vo.uv = vIn.uv;
		vo.color = vIn.color * _Color;
		return vo;
	}

	//https://github.com/stuntrally/stuntrally/blob/master/data/compositor/godrays/godrays.glsl

	//fragmen func
	float4 frag(vertexOut vo) : COLOR
	{
	
		float2 lightPos = float2(_LightX,_LightY);
		float2 deltaTexCoord = (vo.uv - lightPos);

		deltaTexCoord *= 1.0f / _Samples * _Density;
		float4 col = tex2D(_MainTex, vo.uv);
		float illuminationDecay = 1.0f;

		float2 uv2 = vo.uv;

		for (int i = 0; i < _Samples; i++)
		{
			uv2 -= deltaTexCoord;
			float4 samp = tex2D(_MainTex, uv2);
			samp *= illuminationDecay * _Weight;
			col += samp;
			illuminationDecay *= _Decay;
		}

		return float4(col * 0.04);
	}

		ENDCG
	}
	}
}