Shader "3D/LambertSpecularShading"
{
	Properties
	{
		_Color("Tint",Color) = (1.0,1.0,1.0,1.0)
		_SpecularColor("SpecularColor",Color) = (1.0,1.0,1.0,1.0)
		_Power("Power",Range(0,1)) = 1
		_Shininess("Shininess",Float) = 2
	}
		SubShader
	{
		Tags
		{
			"LightMode" = "ForwardBase"
		}

		Pass
		{
		CGPROGRAM

	#pragma vertex vert
	#pragma fragment frag

	uniform fixed4 _Color;
	uniform fixed4 _SpecularColor;
	uniform fixed _Power;
	uniform float _Shininess;

	//unity variables
	uniform fixed4 _LightColor0;

	struct vertexIn
	{
		float4 position : POSITION;
		fixed2 uv : TEXCOORD0;
		float4 color : COLOR;
		float3 normal : NORMAL;
	};

	struct vertexOut
	{
		fixed4 finalPos : SV_POSITION;
		fixed2 uv : TEXCOORD0;
		fixed4 color : COLOR;
	};

	vertexOut vert(vertexIn vi)
	{
		vertexOut vo;
		vo.finalPos = mul(UNITY_MATRIX_MVP, vi.position);

		float3 normalDirection = normalize(mul(_Object2World,float4(vi.normal , 0.0)).xyz);
		//normals are in the object space we need to convert into the world space.

		float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
		float3 viewDirection = normalize(float4(_WorldSpaceCameraPos.xyz,1.0) - mul(_Object2World , vi.position).xyz);

		float3 diffuse = max(0.0 , dot(normalDirection , lightDirection)); // this value is from -1 to  1
																//	diffuse = (diffuse + 1)/2; //both the ways should work

		float3	specular = pow(max(0.0,dot(reflect(-lightDirection, normalDirection) , viewDirection)) , _Shininess) * diffuse;

		float3 finalColor = diffuse  + UNITY_LIGHTMODEL_AMBIENT.xyz + specular;
		vo.uv = vi.uv;
		vo.color = float4(finalColor,0);
		return vo;
	}

	fixed4 frag(vertexOut vo) : COLOR
	{
		return vo.color;
	}


		ENDCG
	}
	}
}
