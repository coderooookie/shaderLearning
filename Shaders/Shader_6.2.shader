
// 漫反射光照模型 —— 逐顶点光照
Shader "Unlit/Shader_6.2" {
	Properties{
		_Diffuse("Diffuse", Color) = (1, 1, 1, 1)
	}
	SubShader{
		Pass{
		Tags{ "LightMode" = "ForwardBase" }
		CGPROGRAM

#pragma vertex vert
#pragma fragment frag
#include "Lighting.cginc"

		uniform fixed4 _Diffuse;

		struct a2v {
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			//float4 texcoord : TEXCOORD0;
		};

		struct v2f {
			float4 pos : SV_POSITION;
			fixed3 worldNormal : TEXCOORD0;
		};

		v2f vert(a2v v) {
			v2f o;
			//计算得到顶点的投影坐标
			o.pos = UnityObjectToClipPos(v.vertex);
			//拿到环境光
			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

			//计算得到世界坐标下的法线向量
			o.worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
			return o;
		}

		fixed4 frag(v2f i) : SV_Target{
			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
			//单位化法线
			fixed3 worldNormal = normalize(i.worldNormal);
			//光线方向
			fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
			//半兰伯特模型
			fixed halfLambert = dot(worldNormal, worldLightDir) * 0.5 + 0.5;
			//漫反射计算
			//fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
			fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * halfLambert;

			fixed3 color = ambient + diffuse;
			return fixed4(color, 0.0);
		}

			ENDCG
		}
	}

	Fallback "Diffuse"

}
