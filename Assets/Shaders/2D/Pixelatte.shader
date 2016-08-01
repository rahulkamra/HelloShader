Shader "2D/Pixelatte"
{
	Properties
	{
		_Color("Tint",Color) = (1.0,1.0,1.0,1.0)
		_MainTex("MainTexture",2D) = "white"{}
	_PixelSize("PixelSize",Range(1,100)) = 1
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
	uniform float _PixelSize;
	uniform float4 _MainTex_TexelSize;

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

	//fragmen func
	float4 frag(vertexOut vo) : COLOR
	{
		float2 div = float2(_PixelSize * _MainTex_TexelSize.x,_PixelSize* _MainTex_TexelSize.y);
		float2  ft0 = vo.uv / div.xy;
		float2 ft1 = ft0.xy - floor(ft0.xy);
		ft0 = ft0 - ft1;
		ft0 = ft0 * div;
		return  tex2D(_MainTex, ft0.xy);
	}

		ENDCG
	}
	}
}