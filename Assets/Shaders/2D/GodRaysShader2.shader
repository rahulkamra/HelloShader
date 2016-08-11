Shader "2D/GodRaysShader2"
{
	Properties
	{
		_Color("Tint",Color) = (1.0,1.0,1.0,1.0)
		_MainTex("MainTexture",2D) = "white"{}
		_Density("Density",Range(0,10)) = 2
		_Samples("Samples",Range(0,100)) = 16
		_Weight("Weight",Range(0,5)) = 0.5
		_Decay("Decay",Range(0,5)) = 0.87
		_Exposure("Exposure",Range(0,5)) = 0.35
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
		
		uniform int _Samples;

		uniform float _LightX;
		uniform float _LightY;
		uniform float _Decay;
		uniform float _Exposure;
		uniform float _Weight;
		uniform float _Density;

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

	//port of https://github.com/devon-o/Starling-Filters/blob/archive/src/starling/filters/GodRaysFilter.as

	//fragmen func
	float4 frag(vertexOut vo) : COLOR
	{
		float4 fc1 = float4(0,0,0,0);
		fc1.x = _Samples;
		fc1.y = _Density;
		fc1.z = _Samples * _Density;
		fc1.w = 1 / fc1.z;

		float4 fc2 = float4(0, 0, 0, 0);
		fc2.x = _Weight;
		fc2.y = _Decay;
		fc2.z = _Exposure;

		float4 fc0 = float4(_LightX, _LightY,1,1);//LightX and Y is already normalized
		float2 ft0 = float2(0, 0);
		ft0.xy = vo.uv - fc0.xy;
		ft0.xy = ft0.xy * fc1.ww;
		float4 ft1 = tex2D(_MainTex, vo.uv);

		float4 ft2 = float4(0, 0, 0, 0);
		float4 ft4 = float4(0, 0, 0, 0);
		ft2.x = fc0.w;
		ft4.xy = vo.uv;

		for (int i = 0; i < _Samples; i++)
		{
			ft4.xy = ft4.xy - ft0.xy;
			float4 ft3 = tex2D(_MainTex, ft4.xy);
			ft2.y = ft2.x * fc2.x;
			ft3.xyz = ft3.xyz * ft2.yyy;
			ft1.xyz = ft1.xyz + ft3.xyz;
			ft2.x = ft2.x * fc2.y;
		}

		ft1.xyz = ft1.xyz * fc2.zzz;
		return ft1;
	}

		ENDCG
	}
	}
}