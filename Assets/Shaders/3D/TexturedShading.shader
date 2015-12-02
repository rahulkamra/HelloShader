Shader "3D/TexturedLighting"
{
	Properties
	{
		_Color("Tint",Color) = (1.0,1.0,1.0,1.0)
		_MainTex("MainTexture",2D) = "white"{}
		_SpecularColor("SpecularColor",Color) = (1.0,1.0,1.0,1.0)

		_Power("Power",Range(0,1)) = 0.3

		_Shininess("Shininess",Float) = 2

	}
		SubShader
		{


			Pass
		{

			Tags{ "LightMode" = "ForwardBase" }
			CGPROGRAM

	#pragma vertex vert
	#pragma fragment frag
	#include "UnityCG.cginc"

	uniform sampler2D _MainTex;
	uniform float4 _MainTex_ST;
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
		fixed3 normalDirection : NORMAL;
		fixed3 viewDirection : TEXCOORD4;
		fixed3 posWorld : TEXCOORD5;
	};

	vertexOut vert(vertexIn vi)
	{
		vertexOut vo;
		vo.finalPos = mul(UNITY_MATRIX_MVP, vi.position);
		vo.normalDirection = mul(_Object2World, float4(vi.normal, 0.0)).xyz;

		vo.uv = TRANSFORM_TEX(vi.uv,_MainTex);

		float3 posWorld = mul(_Object2World, vi.position).xyz;
		vo.viewDirection = normalize(_WorldSpaceCameraPos.xyz - posWorld);
		vo.posWorld = posWorld;
		return vo;
	}

	fixed4 frag(vertexOut vo) : COLOR
	{
		//normals are in the object space we need to convert into the world space.
		float3 normalDirection = normalize(vo.normalDirection);
		//from the vertex towards the light
		float3 viewDirection = vo.viewDirection;

		float3 lightDirection;
		fixed atten;
		if (_WorldSpaceLightPos0.w == 0)
		{
			lightDirection = normalize(_WorldSpaceLightPos0.xyz);
			atten = 1.0;
		}
		else
		{
			lightDirection = _WorldSpaceLightPos0.xyz - vo.posWorld;
			atten = 1 / length(lightDirection);
			lightDirection = lightDirection*atten;
		}


		float3 diffuse = max(0.0, dot(normalDirection, lightDirection)); // this value is from -1 to  1
																		 //	diffuse = (diffuse + 1)/2; //both the ways should work
		float3 diffuseFinal = diffuse  *_Power;

		float3	specular = pow(max(0.0, dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shininess) * diffuse * _SpecularColor * _Power;



		float3 finalColor = diffuseFinal + specular +UNITY_LIGHTMODEL_AMBIENT.xyz;
		fixed4 color = float4(finalColor *_LightColor0 * _Color, 0)  * atten;


		fixed4 tex = tex2D(_MainTex, vo.uv);

		return color * tex;
	}


		ENDCG
	}


		Pass
	{
		Tags{ "LightMode" = "ForwardAdd" }
		Blend One One
		CGPROGRAM

#pragma vertex vert
#pragma fragment frag

		uniform fixed4 _Color;
	uniform fixed4 _SpecularColor;
	uniform fixed4 _RimColor;

	uniform fixed _Power;
	uniform fixed _RimPower;
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
		fixed3 normalDirection : NORMAL;
		fixed3 viewDirection : TEXCOORD4;
		fixed3 posWorld : TEXCOORD5;
	};

	vertexOut vert(vertexIn vi)
	{
		vertexOut vo;
		vo.finalPos = mul(UNITY_MATRIX_MVP, vi.position);
		vo.normalDirection = mul(_Object2World, float4(vi.normal, 0.0)).xyz;

		vo.uv = vi.uv;

		float3 posWorld = mul(_Object2World, vi.position).xyz;
		vo.viewDirection = normalize(_WorldSpaceCameraPos.xyz - posWorld);
		vo.posWorld = posWorld;
		return vo;
	}

	fixed4 frag(vertexOut vo) : COLOR
	{
		//normals are in the object space we need to convert into the world space.
		float3 normalDirection = normalize(vo.normalDirection);
		//from the vertex towards the light
		float3 viewDirection = vo.viewDirection;

		float3 lightDirection;
		fixed atten;
		if (_WorldSpaceLightPos0.w == 0)
		{
			lightDirection = normalize(_WorldSpaceLightPos0.xyz);
			atten = 1.0;
		}
		else
		{
			lightDirection = _WorldSpaceLightPos0.xyz - vo.posWorld;
			atten = 1 / length(lightDirection);
			lightDirection = lightDirection*atten;
		}


		float3 diffuse = max(0.0, dot(normalDirection, lightDirection)); // this value is from -1 to  1
																		 //	diffuse = (diffuse + 1)/2; //both the ways should work
		float3 diffuseFinal = diffuse  *_Power;

		float3	specular = pow(max(0.0, dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shininess) * diffuse * _SpecularColor * _Power;







		float3 finalColor = diffuseFinal + specular;
		fixed4 color = float4(finalColor *_LightColor0 * _Color, 0)  * atten;
		return color;
	}


		ENDCG
	}
	}
}
