// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'


// 漫反射光照模型 —— 逐顶点光照
Shader "Unlit/Shader_6.3" {
	Properties{
		_Diffuse("Diffuse", Color) = (1, 1, 1, 1)
		_Specular ("Specular", Color) = (1,1,1,1)
		_Gloss ("Gloss", Range(8.0, 256)) = 20
	}
	SubShader{
		Pass{
		Tags{ "LightMode" = "ForwardBase" }
		CGPROGRAM

#pragma vertex vert
#pragma fragment frag
#include "Lighting.cginc"

		uniform fixed4 _Diffuse;
		fixed4 _Specular;
		float _Gloss;

		struct a2v {
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			//float4 texcoord : TEXCOORD0;
		};

		struct v2f {
			float4 pos : SV_POSITION;
			fixed3 color : COLOR;
		};

		v2f vert(a2v v) {
			v2f o;
			//计算得到顶点的投影坐标
			o.pos = UnityObjectToClipPos(v.vertex);
			//拿到环境光
			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

			//计算得到世界坐标下的法线向量
			fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
			//计算光线方向
			fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
			//半兰伯特模型
			fixed halfLambert = dot(worldLightDir, worldNormal) * 0.5 + 0.5;
			//漫反射计算
			fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * halfLambert;

			//计算反射向量
			fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
			//计算视角方向
			fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);
			//反射光计算
			fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);
 
			o.color = ambient + diffuse + specular;

			return o;
		}

		fixed4 frag(v2f i) : SV_Target{
			return fixed4(i.color, 1.0);
		}

			ENDCG
		}
	}

	Fallback "Specular"

}
