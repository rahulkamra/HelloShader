Shader "3D/DefaultColor" 
{
	Properties
	{
		_Color("Tint",Color) = (1.0,1.0,1.0,1.0)
	}
		SubShader
	{
		Tags
		{

		}

		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			uniform fixed4 _Color;
			struct vertexIn
			{
				float4 position : POSITION;
				fixed2 uv : TEXCOORD0;
				float4 color : COLOR;
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
				vo.uv = vi.uv;
				vo.color = vi.color * _Color;
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
