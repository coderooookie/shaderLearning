
// 世界坐标系法线纹理
Shader "Unlit/Shader_7.3" {
		Properties{
			//_Diffuse("Diffuse", Color) = (1, 1, 1, 1)
			_Color("Color Tint", Color) = (1,1,1,1)
			_MainTex("Main Tex", 2D) = "white" {}
			_BumpMap("Normal Map", 2D) = "bump" {}
			_BumpScale("Bump Scale", Float) = 1.0
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
			float4 TtoW0 : TEXCOORD1;
			float4 TtoW1 : TEXCOORD2;
			float4 TtoW2 : TEXCOORD3;
		};

		v2f vert(a2v v) {
			v2f o;
			//计算得到顶点的投影坐标
			o.pos = UnityObjectToClipPos(v.vertex);
			//纹理UV坐标
			o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
			//法线纹理UV坐标
			o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
			
			//计算世界坐标下的切线相关向量
			float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
			fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
			fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
			fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

			//保存切线相关向量矩阵
			//w分量保存了顶点的世界坐标
			o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
			o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
			o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

			return o;
		}

		fixed4 frag(v2f i) : SV_Target{
			//世界坐标顶点
			float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);

			fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
			fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
			//切线向量
			fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
			bump.xy *= _BumpScale;
			bump.z = sqrt(1.0 - saturate(dot(bump.xy, bump.xy)));
			//世界坐标下的切线向量
			bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));

			//纹理采样
			fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
			//环境光
			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
			//漫反射
			fixed3 diffuse = _LightColor0.rgb * albedo *max(0, dot(bump, lightDir));
			//反射光
			fixed3 halfDir = normalize(lightDir + viewDir);
			fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(bump, halfDir)), _Gloss);

			return fixed4(ambient + diffuse + specular, 1.0);
		}

			ENDCG
		}
		}

			Fallback "Specular"

	}
