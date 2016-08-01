Shader "2D/NoiseSprite"
{
	Properties
	{
		_Color("Tint",Color) = (1.0,1.0,1.0,1.0)
		_MainTex("MainTexture",2D) = "white"{}
		_SeedX("SeedX",Range(0,2)) = 1
		_SeedY("SeedY",Range(0,2)) = 1
		_Amount("Amount",Range(0,1)) = 0
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
		uniform float _SeedX;
		uniform float _SeedY;
		uniform float _Amount;

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

	float getRandomNumber(float2 seed)
	{
		float a = 12.9898;
		float b = 78.233;
		float c = 43758.5453;
		float dt = dot(seed.xy, float2(a, b));
		float sn = fmod(dt, 3.14);
		return frac(sin(sn) * c);
	}
	//fragmen func
	float4 frag(vertexOut vo) : COLOR
	{
		float4 tex = tex2D(_MainTex, vo.uv) * vo.color;
		float2 ft1 = vo.uv;
		ft1.xy = ft1.xy + float2(_SeedX, _SeedY);
		ft1.x = getRandomNumber(float2(_SeedX, _SeedY)) *_Amount;
		tex.x = tex.x - ft1.x;
		tex.y = tex.y - ft1.x;
		tex.z = tex.z - ft1.x;
		return tex;
		return float4(ft1.x, ft1.x, ft1.x,1);
	}

		ENDCG
	}
	}
}