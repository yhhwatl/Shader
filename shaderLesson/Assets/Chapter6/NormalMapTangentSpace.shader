// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/NormalMapTangentSpace" {
//纹理坐标与位置坐标，可以通过切线空间联系起来。
	Properties {
		_Color ("Color Tint",Color) = (1,1,1,1)
		_MainTex ("Main Tex",2D) = "white" {}
		_BumpMap ("Normal Map",2D) = "bump" {}//法线纹理 bump是unity内置的法线纹理，当没有提供任何法线纹理时，“bump”就对应了模型自带的法线信息。
		_BumpScale ("Bump Scale",Float) = 1.0//用于控制凹凸程度，当它为0时，意味着该法线纹理不会对光照产生任何影响。
		_Specular ("Specular",Color) = (1,1,1,1)
		_Gloss ("Gloss",Range(8.0,256)) = 20
	}
	SubShader {
	
		Pass {
			Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM
		
			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;//为了得到该纹理的属性（平移和偏移系数），我们为_MainTex和_BumpMap定义了_MainTex_ST和_BumpMap_ST变量。
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			fixed4 _Specular;
			float _Gloss;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;//顶点的切线方向 tangent.w分量决定切线空间的第三个坐标轴——副切线的方向性。
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
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

				TANGENT_SPACE_ROTATION;
				
				o.lightDir = mul(rotation,ObjSpaceLightDir(v.vertex)).xyz;
				o.viewDir = mul(rotation,ObjSpaceViewDir(v.vertex)).xyz;
				
				return o;
			}

			fixed4 frag(v2f i) : SV_Target {
				fixed3 tangentLightDir = normalize(i.lightDir);
				fixed3 tangentViewDir = normalize(i.viewDir);

				fixed4 packedNormal = tex2D(_BumpMap,i.uv.zw);
				fixed3 tangentNormal;
				//tangentNormal.xy = (packedNormal.xy * 2 -1) * _BumpScale;
				//tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy,tangentNormal.xy)));
				tangentNormal = UnpackNormal(packedNormal);
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy,tangentNormal.xy)));

				fixed3 albedo = tex2D(_MainTex,i.uv).rgb * _Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(tangentNormal,tangentLightDir));

				fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(tangentNormal,halfDir)),_Gloss);

				return fixed4(ambient + diffuse + specular,1.0);  
			}
			
			ENDCG

		}


	}
	Fallback "Specular"
}
