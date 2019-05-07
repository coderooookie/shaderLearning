﻿// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'


// 漫反射光照模型 —— 逐顶点光照
Shader "Unlit/Shader_6.1" {
	Properties {
		_Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
	}
	SubShader {
        Pass {
        	Tags {"LightMode" = "ForwardBase" }
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            uniform fixed4 _Diffuse;

			struct a2v {
                float4 vertex : POSITION;
				float3 normal : NORMAL;
//				float4 texcoord : TEXCOORD0;
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
            	//获取光照方向
            	fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
            	//计算漫反射
            	fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));
     			//环境光加漫反射
            	o.color = ambient + diffuse;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                return fixed4(i.color, 1.0);
            }

            ENDCG
        }
    }

    Fallback "Diffuse"

}