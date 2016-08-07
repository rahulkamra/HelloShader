Shader "2D/GodRaysShader"
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
		float2 lightDirection = float2(0.5,0.5);
		float steps = 20;//fc1.x
		float density = 2;//fc1.y

		//fc1.z = steps*density;
		//fc1.w = 1/steps*density;

		float weight = 0.5;//fc2.x
		float decay = 0.87;//fc2.y
		float exposure = 0.35;//fc2.z

		float numSamples = 20;

		float2 lightToPixel = vo.uv - lightDirection;
		float4 tex = tex2D(_MainTex, vo.uv) * vo.color;
		return tex;
	}

		ENDCG
	}
	}
}