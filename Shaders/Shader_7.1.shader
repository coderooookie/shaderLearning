
// 基础纹理
Shader "Unlit/Shader_7.1" {
	Properties{
		//_Diffuse("Diffuse", Color) = (1, 1, 1, 1)
		_Color ("Color Tint", Color) = (1,1,1,1)
		_MainTex("Main Tex", 2D) = "white" {}
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

		fixed4 _Color;
		sampler2D _MainTex;
		float4 _MainTex_ST;
		fixed4 _Specular;
		float _Gloss;

		struct a2v {
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			float4 texcoord : TEXCOORD0;
		};

		struct v2f {
			float4 pos : SV_POSITION;
			float3 worldNormal : TEXCOORD0;
			float3 worldPos : TEXCOORD1;
			float2 uv : TEXCOORD2;
		};

		v2f vert(a2v v) {
			v2f o;
			//计算得到顶点的投影坐标
			o.pos = UnityObjectToClipPos(v.vertex);
			
			//计算得到世界坐标下的法线向量
			o.worldNormal = UnityObjectToWorldNormal(v.normal);
			//世界坐标位置
			o.worldPos = mul(unity_ObjectToWorld, v.vertex);
			//纹理UV坐标
			o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

			return o;
		}

		fixed4 frag(v2f i) : SV_Target{
			fixed3 worldNormal = normalize(i.worldNormal);
			fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

			//纹理采样
			fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
			//环境光
			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
			//漫反射
			fixed3 diffuse = _LightColor0.rgb * albedo *max(0, dot(worldNormal, worldLightDir));
			//反射光
			fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
			fixed3 halfDir = normalize(worldLightDir + viewDir);
			fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

			return fixed4(ambient + diffuse + specular, 1.0);
		}

			ENDCG
		}
	}

	Fallback "Specular"

}
