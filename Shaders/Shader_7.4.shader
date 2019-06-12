
// 渐变纹理
Shader "Unlit/Shader_7.4" {
		Properties{
			//_Diffuse("Diffuse", Color) = (1, 1, 1, 1)
			_Color("Color Tint", Color) = (1,1,1,1)
			_RampTex("Ramp Tex", 2D) = "white" {}
			_Specular("Specular", Color) = (1,1,1,1)
			_Gloss("Gloss", Range(8.0, 256)) = 20
		}
	SubShader{
		Pass{
		Tags{ "LightMode" = "ForwardBase" }
		CGPROGRAM

#pragma vertex vert
#pragma fragment frag
#include "Lighting.cginc"

		fixed4 _Color;
		sampler2D _RampTex;
		float4 _RampTex_ST;
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

			o.worldNormal = UnityObjectToWorldNormal(v.normal);

			o.worldPos = UnityObjectToClipPos(v.vertex);
			//渐变纹理坐标
			o.uv = TRANSFORM_TEX(v.texcoord, _RampTex);
		

			return o;
		}

		fixed4 frag(v2f i) : SV_Target{
			//世界坐标顶点
			fixed3 worldNormal = normalize(i.worldNormal);
			fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

			//环境光
			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
			//漫反射
			fixed halfLambert = 0.5 * dot(worldNormal, worldLightDir) + 0.5;
			fixed3 diffuseColor = tex2D(_RampTex, fixed2(halfLambert, halfLambert)).rgb * halfLambert * _Color.rgb;
			fixed3 diffuse = diffuseColor * _LightColor0.rgb; //左乘与右乘
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
