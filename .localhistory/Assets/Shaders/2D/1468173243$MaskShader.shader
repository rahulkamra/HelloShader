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
		uniform sampler2D _MainTex;
		uniform sampler2D _MaskTexture;
		float4 _MainTex_ST;
		float4 _MaskTexture_ST;
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

		vo.uv = TRANSFORM_TEX(vIn.uv,_MainTex);
		vo.uv1 = TRANSFORM_TEX(vIn.uv1, _MaskTexture);
		vo.color = vIn.color * _Color;
		return vo;
	}

	//fragmen func
	fixed4 frag(vertexOut vo) : COLOR
	{
		fixed4 tex = tex2D(_MainTex, vo.uv) * vo.color;
		fixed4 tex2 = tex2D(_MaskTexture, vo.uv1) * vo.color;

		tex2.w = fixed(tex.w);
		return  fixed4(tex2.rgb, tex.w) * fixed4(tex.w, tex.w, tex.w, tex.w);

		//tex2.w = 1;
		if (tex2.w == 0)
			return fixed4(1,1,1,0);
		else
			return fixed4(tex2.x, tex2.y, tex2.z, tex.w);

	}

		ENDCG
	}
	}
}