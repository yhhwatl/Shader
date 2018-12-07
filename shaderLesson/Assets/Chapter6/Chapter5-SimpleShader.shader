// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'
//5.2 一个简单的顶点/片元着色器
//5.2.1基本结构
Shader "Custom/Chapter5" {
	Properties {
		//声明Color属性
		_Color ("Color Tint",Color) = (1.0,1.0,1.0,1.0)
	}
	SubShader {
		Pass {
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			// 需要定义一个与属性名称和类型都匹配的变量
			fixed4 _Color;

			struct a2v {
				float4 vertex : POSITION;//顶点坐标
				float3 normal : NORMAL;//法线
				float4 texcoord : TEXCOORD0;//文理坐标
			};
			struct v2f {
				float4 pos : SV_POSITION;
				fixed3 color : COLOR0;
			};
			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.color = v.normal * 0.5 + fixed3(0.5,0.5,0.5);
				return o;
			}
			//v2f是vert返回值进行插值后得到的结果
			fixed4 frag(v2f o) : SV_Target {
				fixed3 c = o.color;
				// 使用_Color控制输出颜色
				c *= _Color.rgb;
				return fixed4(c,1.0);
			}

			ENDCG
		}
	}
}
//5.2.2 模型数据哪里来
//POSITION,NORMAL,TEXCOORD0从拥有该材质的Mesh Render组件中提供，在每帧DrawCall中MeshRender把模型数据传递给Shader
//每个模型有许多三角形面片组成，每个三角形面片包含三个顶点，每个顶点包含坐标，法线，纹理，颜色等数据。
//5.2.3 顶点着色器与片元着色器通信 v2f是vert返回值进行插值后得到的结果





























