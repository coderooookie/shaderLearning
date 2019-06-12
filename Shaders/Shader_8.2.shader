
// 透明混合
Shader "Unlit/Shader_8.2" {
	Properties{
			//_Diffuse("Diffuse", Color) = (1, 1, 1, 1)
			_Color("Color Tint", Color) = (1,1,1,1)
			_MainTex("Main Tex", 2D) = "white" {}
			_AlphaScale("Alpha Scale", Range(0, 1)) = 1
	}
	SubShader{
		Tags{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}
		Pass{
			Tags{ "LightMode" = "ForwardBase" }
		
			Zwrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM

#pragma vertex vert
#pragma fragment frag
#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed _AlphaScale;

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
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
		

				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				//世界坐标顶点
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				fixed4 texColor = tex2D(_MainTex, i.uv);

				//片元颜色
				fixed3 albedo = texColor.rgb * _Color.rgb;

				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				//漫反射
				fixed halfLambert = 0.5 * dot(worldNormal, worldLightDir) + 0.5;
				//fixed3 diffuseColor = tex2D(_RampTex, fixed2(halfLambert, halfLambert)).rgb * halfLambert * _Color.rgb;
				fixed3 diffuse = halfLambert * _LightColor0.rgb * albedo; //左乘与右乘

				return fixed4(ambient + diffuse, texColor.a * _AlphaScale);
			}

			ENDCG
		}
	}

	Fallback "Transparent/VertexLit"
}
