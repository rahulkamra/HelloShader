Shader "3D/NormalMapShading"
{
	Properties
	{
		_Color("Tint",Color) = (1.0,1.0,1.0,1.0)
		_MainTex("MainTexture",2D) = "white"{}
		_BumpTex("BumpTexture",2D) = "bump"{}
		_Bumpiness("Bumpiness",Range(-1,10)) = 1

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

	uniform sampler2D _BumpTex;
	uniform float4 _BumpTex_ST;

	uniform float _Bumpiness;

	uniform fixed4 _Color;
	uniform fixed4 _SpecularColor;


	uniform fixed _Power;
	uniform float _Shininess;

	//unity variables
	uniform fixed4 _LightColor0;

	struct vertexIn
	{
		float4 position : POSITION;
		fixed2 texcoord : TEXCOORD0;
		fixed2 texcoord1 : TEXCOORD1;

		float4 color : COLOR;
		float3 normal : NORMAL;
		float3 tangent : TANGENT;
	};

	struct vertexOut
	{
		fixed4 finalPos : SV_POSITION;
		fixed2 texcoord : TEXCOORD0;
		fixed2 texcoord1 : TEXCOORD1;

		fixed3 normalDirection : NORMAL;
		fixed3 tangentDirection : TEXCOORD4;
		fixed3 binormalDirection : TEXCOORD5;

		fixed3 viewDirection : TEXCOORD6;
		fixed3 posWorld : TEXCOORD7;
	};

	vertexOut vert(vertexIn v)
	{
		vertexOut vo;
		vo.finalPos = mul(UNITY_MATRIX_MVP, v.position);

		vo.normalDirection = mul(_Object2World, float4(v.normal, 0.0)).xyz;
		vo.tangentDirection = mul(_Object2World, float4(v.tangent, 0.0)).xyz;
		vo.binormalDirection  = cross(vo.normalDirection, vo.tangentDirection);

		vo.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
		vo.texcoord1 = v.texcoord1.xy * _BumpTex_ST.xy + _BumpTex_ST.zw;

		

		float3 posWorld = mul(_Object2World, v.position).xyz;
		vo.viewDirection = normalize(_WorldSpaceCameraPos.xyz - posWorld);
		vo.posWorld = posWorld;
		return vo;
	}

	fixed4 frag(vertexOut vo) : COLOR
	{
		fixed4 tex = tex2D(_MainTex, vo.texcoord);
		fixed4 bumpTex = tex2D(_BumpTex, vo.texcoord1); // range is from 0 to 1 to make the range to -1 to 1  = 2*value -1

		//unity store normals in alpha and green channel;
		float3 localCoordinates = float3(2 * bumpTex.ag - float2(1.0, 1.0), 0);
		localCoordinates.z = (1 - 0.5 * dot(localCoordinates, localCoordinates)) * _Bumpiness;
		float3x3 tbnMatrix = float3x3
			(
				normalize(vo.tangentDirection),
				normalize(vo.binormalDirection),
				normalize(vo.normalDirection)
			);
		//normals are in the object space we need to convert into the world space.
		float3 normalDirection = normalize(mul(tbnMatrix,localCoordinates)); // converting the coordinates into the worldspace.
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



		float3 finalColor = diffuseFinal + specular + UNITY_LIGHTMODEL_AMBIENT.xyz;
		fixed4 color = float4(finalColor *_LightColor0 * _Color, 0)  * atten;


		

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
#include "UnityCG.cginc"

		uniform sampler2D _MainTex;
	uniform float4 _MainTex_ST;

	uniform sampler2D _BumpTex;
	uniform float4 _BumpTex_ST;

	uniform float _Bumpiness;

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
		fixed2 nuv : TEXCOORD1;

		float4 color : COLOR;
		float3 normal : NORMAL;
		float3 tangent : TANGENT;
	};

	struct vertexOut
	{
		fixed4 finalPos : SV_POSITION;
		fixed2 uv : TEXCOORD0;
		fixed2 nuv : TEXCOORD1;

		fixed3 normalDirection : NORMAL;
		fixed3 tangentDirection : TEXCOORD4;
		fixed3 binormalDirection : TEXCOORD5;

		fixed3 viewDirection : TEXCOORD6;
		fixed3 posWorld : TEXCOORD7;
	};

	vertexOut vert(vertexIn vi)
	{
		vertexOut vo;
		vo.finalPos = mul(UNITY_MATRIX_MVP, vi.position);

		vo.normalDirection = mul(_Object2World, float4(vi.normal, 0.0)).xyz;
		vo.tangentDirection = mul(_Object2World, float4(vi.tangent, 0.0)).xyz;
		vo.binormalDirection = cross(vo.normalDirection, vo.tangentDirection);

		vo.uv = TRANSFORM_TEX(vi.uv,_MainTex);
		vo.nuv = TRANSFORM_TEX(vi.nuv, _BumpTex);



		float3 posWorld = mul(_Object2World, vi.position).xyz;
		vo.viewDirection = normalize(_WorldSpaceCameraPos.xyz - posWorld);
		vo.posWorld = posWorld;
		return vo;
	}

	fixed4 frag(vertexOut vo) : COLOR
	{
		fixed4 tex = tex2D(_MainTex, vo.uv);
	fixed4 bumpTex = tex2D(_BumpTex, vo.uv); // range is from 0 to 1 to make the range to -1 to 1  = 2*value -1

											 //unity store normals in alpha and green channel;
	float3 localCoordinates = float3(2 * bumpTex.ag - float2(1.0, 1.0), 0);
	localCoordinates.z = (1 - 0.5 * dot(localCoordinates, localCoordinates)) * _Bumpiness;
	float3x3 tbnMatrix = float3x3
		(
			normalize(vo.tangentDirection),
			normalize(vo.binormalDirection),
			normalize(vo.normalDirection)
			);
	//normals are in the object space we need to convert into the world space.
	float3 normalDirection = normalize(mul(tbnMatrix,localCoordinates)); // converting the coordinates into the worldspace.
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




	return color ;
	}
		ENDCG
	}

	}
}
