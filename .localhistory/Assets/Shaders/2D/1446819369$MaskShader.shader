Shader "2D/Mask"
{
	Properties
	{
		_Color("Tint",Color) = (1.0,1.0,1.0,1.0)
		_MainTex("MainTexture",2D) = "white"{}
		_MaskTexture("Mask",2D) = "white"{}
		_Intr("Intr",Range(0,1)) = 1
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
		#include "UnityCG.cginc"
		//variables
		uniform sampler2D _MainTexT;
		uniform sampler2D _MaskTexture;
		uniform fixed4 _Color;
		uniform fixed _Intr;

	struct vertexIn
	{
		fixed4 vertex : POSITION;
		fixed2 uv : TEXCOORD0;
		fixed2 uv1 : TEXCOORD1;
		fixed4 color : COLOR;
	};

	struct vertexOut
	{
		fixed4 finalPos : SV_POSITION;
		fixed2 uv : TEXCOORD0;
		fixed2 uv1 : TEXCOORD1;
		fixed4 color : COLOR;
	};



	//vertex func
	vertexOut vert(vertexIn vIn)
	{
		vertexOut vo;
		vo.finalPos = mul(UNITY_MATRIX_MVP , vIn.vertex);

		vo.uv = TRANSFORM_TEX(_MainTex,vIn.uv);
		vo.uv = vIn.uv;
		vo.uv1 = vIn.uv1;
		vo.color = vIn.color * _Color;
		return vo;
	}

	//fragmen func
	fixed4 frag(vertexOut vo) : COLOR
	{
		return tex2D(_MaskTexture, vo.uv1);
		fixed4 tex = tex2D(_MainTexT, vo.uv) * vo.color;
		fixed grayValue = (tex.x + tex.y + tex.z) / 3;
		fixed4 grayColor = fixed4(grayValue, grayValue, grayValue, tex.w);
		return lerp(tex, grayColor, _Intr);

	}

		ENDCG
	}
	}
}