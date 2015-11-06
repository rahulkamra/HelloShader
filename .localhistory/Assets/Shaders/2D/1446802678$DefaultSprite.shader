Shader "2D/DefaultSprite"
{
	Properties
	{
		_MulColor("MulColor",Color) = (1.0,1.0,1.0,1.0)
		_AddColor("AddColor",Color) = (0.0,0.0,0.0,0.0)
		_MainTex("MainTexture",2D) = "white"{}
	}
		SubShader
		{
			Tags
			{

			}
			Pass
			{
				CGPROGRAM

				//pragma
				#pragma vertex vert
				#pragma fragment frag

				//variables
				uniform sampler2D _MainTex;
				uniform float4 _MulColor;
				uniform float4 _AddColor;
				uniform float4 _DivideColor;
				uniform fixed _Slider;

				struct vertexIn
				{
					float4 vertex:POSITION;
					float2 uv:TEXCOORD0;
				};

				struct vertexOut
				{
					float4 finalPos:SV_POSITION;
					float2 uv:TEXCOORD0;
				};



				//vertex func
				vertexOut vert(vertexIn vIn)
				{
					vertexOut vo;
					vo.finalPos = mul(UNITY_MATRIX_MVP , vIn.vertex);
					vo.uv = vIn.uv;
					return vo;
				}

				//fragmen func
				float4 frag(vertexOut vo) : COLOR
				{

					return tex2D(_MainTex, vo.uv) * _MulColor + _AddColor;
				/*float4 from = tex2D(_MainTex,vo.uv);
				float4 to = float4(from.x, from.x, from.x, from.x);

				fixed returnR = from.x + (to.x - from.x)*_Slider;
				fixed returnG = from.y + (to.y - from.y)*_Slider;
				fixed returnB = from.z + (to.z - from.z)*_Slider;
				return  float4(returnR, returnG, returnB,1);*/

				//return float4(tex.x, tex.x, tex.x, tex.x);

				return (_MulColor * tex2D(_MainTex, vo.uv) + _AddColor);
				}

		ENDCG
	}
	}
}