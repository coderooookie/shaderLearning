
// 内置方法实现阴影和光照衰减
Shader "Unlit/Shader_9.3" {
	Properties{
		_Diffuse("Diffuse", Color) = (1, 1, 1, 1)
		_Specular("Specular", Color) = (1,1,1,1)
		_Gloss("Gloss", Range(8.0, 256)) = 20
	}
	SubShader{
		Pass{
			Tags{ "LightMode" = "ForwardBase" }
			CGPROGRAM

#pragma multi_compile_fwdbase

#pragma vertex vert
#pragma fragment frag
#include "Lighting.cginc"
#include "AutoLight.cginc"

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				//float4 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				SHADOW_COORDS(2)
			};

			v2f vert(a2v v) {
				v2f o;
				//计算得到顶点的投影坐标
				o.pos = UnityObjectToClipPos(v.vertex);

				//计算得到世界坐标下的法线向量
				o.worldNormal = UnityObjectToWorldNormal(v.normal);

				//计算得到顶点的世界坐标
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				//计算阴影纹理坐标
				TRANSFER_SHADOW(o);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				//单位化法线
				fixed3 worldNormal = normalize(i.worldNormal);
				//光线方向
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				//漫反射计算
				//fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));

				//视角方向
				// fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.pos));
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
				fixed3 halfDir = normalize(worldLightDir + viewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

				//// 平行光，衰减值永远为1
				//fixed atten = 1.0;

				// 阴影
				//fixed shadow = SHADOW_ATTENUATION(i);
				//return fixed4(ambient + (diffuse + specular) * atten * shadow, 1.0);

				//内置方法处理光照衰减和阴影
				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
				return fixed4(ambient + (diffuse + specular) * atten, 1.0);
			}

			ENDCG
		}

		Pass{
			Tags{ "LightMode" = "ForwardAdd" }

			Blend One One
			CGPROGRAM

#pragma multi_compile_fwdadd

#pragma vertex vert
#pragma fragment frag
#include "Lighting.cginc"
#include "AutoLight.cginc"

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
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
			};

			v2f vert(a2v v) {
				v2f o;
				//计算得到顶点的投影坐标
				o.pos = UnityObjectToClipPos(v.vertex);

				//计算得到世界坐标下的法线向量
				o.worldNormal = UnityObjectToWorldNormal(v.normal);

				//计算得到顶点的世界坐标
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target{

				//单位化法线
				fixed3 worldNormal = normalize(i.worldNormal);
				//光线方向
#ifdef USING_DIRECTIONAL_LIGHT
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
#else
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
#endif
				//漫反射计算
				//fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));

				//视角方向
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 halfDir = normalize(worldLightDir + viewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);
#ifdef USING_DIRECTIONAL_LIGHT
				// 平行光，衰减值永远为1
				fixed atten = 1.0;
#else
				float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1)).xyz;
				fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
#endif
				return fixed4((diffuse + specular) * atten, 1.0);
			}

			ENDCG
		}

	}

	Fallback "Specular"

}