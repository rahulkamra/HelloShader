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

	//http://byteblacksmith.com/improvements-to-the-canonical-one-liner-glsl-rand-for-opengl-es-2-0/
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
		float4 texColor = tex2D(_MainTex, vo.uv);
		float2 seed = vo.uv + float2(_SeedX, _SeedY);;
		float rand = getRandomNumber(seed) * _Amount;
		texColor.xyz = texColor.xyz - float3(rand, rand, rand);
		return texColor;
		
	}
		ENDCG
	}
	}
}