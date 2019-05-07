
// 法线纹理
Shader "Unlit/Shader_7.2" {
	Properties{
		//_Diffuse("Diffuse", Color) = (1, 1, 1, 1)
		_Color ("Color Tint", Color) = (1,1,1,1)
		_MainTex("Main Tex", 2D) = "white" {}
		_BumpMap("Normal Map", 2D) = "bump" {}
		_BumpScale ("Bump Scale", Float) = 1.0
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
		sampler2D _BumpMap;
		float4 _BumpMap_ST;
		float _BumpScale;
		fixed4 _Specular;
		float _Gloss;

		struct a2v {
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			float4 tangent : TANGENT;
			float4 texcoord : TEXCOORD0;
		};

		struct v2f {
			float4 pos : SV_POSITION;
			float4 uv : TEXCOORD0;
			float3 lightDir : TEXCOORD1;
			float3 viewDir : TEXCOORD2;
		};

		v2f vert(a2v v) {
			v2f o;
			//计算得到顶点的投影坐标
			o.pos = UnityObjectToClipPos(v.vertex);
			//纹理UV坐标
			o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
			//法线纹理UV坐标
			o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
			//内置方法实现空间的矩阵变换
			TANGENT_SPACE_ROTATION;

			//将光照方向变换到切线坐标
			o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
			//将视角方向变换到切线坐标
			o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;
			

			return o;
		}

		fixed4 frag(v2f i) : SV_Target{
			fixed3 tangentLightDir = normalize(i.lightDir);
			fixed3 tangentViewDir = normalize(i.viewDir);

			fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
			fixed3 tangentNormal;

			tangentNormal = UnpackNormal(packedNormal);
			tangentNormal.xy *= _BumpScale;
			tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

			//纹理采样
			fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
			//环境光
			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
			//漫反射
			fixed3 diffuse = _LightColor0.rgb * albedo *max(0, dot(tangentNormal, tangentLightDir));
			//反射光
			fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
			fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss);

			return fixed4(ambient + diffuse + specular, 1.0);
		}

			ENDCG
		}
	}

	Fallback "Specular"

}
