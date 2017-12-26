// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Custom/CandyShader"
{
	Properties
	{
		_CandyColor ("Candy Color", Color) = (1,1,1,1)
		_SparkleColor("Sparkle Color", Color) = (1,1,1,1)
		_NoiseTex("Noise Texture", 2D) = "white" {}
		_ColorNoiseTex("Color Noise Texture", 2D) = "white" {}
		_BubbleTex ("Bubble Texture", 2D) = "white" {}
		_Transparency("Transparency", Range(0,1)) = 0.25
		_RimStrength("Rim Strength", Range(0,1)) = 0.25
		_Ramp("Ramp", Range(-1,1)) = 0.25

		_Subtraction("Subtraction", Range(0,1)) = 0.9
		_SparkleStrength("Sparkle Strength", Range(0,10)) = 10
	}
	SubShader
	{
		Tags{ "Queue" = "Transparent" "RenderType" = "Transparent" }
		LOD 200
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float3 normalDir: TEXCOORD1;
				float4 worldPos: TEXCOORD2;
			};

			sampler2D _NoiseTex;
			float4 _NoiseTex_ST;

			sampler2D _ColorNoiseTex;
			float4 _ColorNoiseTex_ST;

			sampler2D _BubbleTex;
			float4 _BubbleTex_ST;

			float4 _CandyColor;
			float4 _SparkleColor;

			float _Transparency;
			float _RimStrength;
			float _Ramp;

			float _SparkleStrength;
			float _Subtraction;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _BubbleTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				o.normalDir = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				//o.vertex = mul(_Object2World, v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{

				float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
				//float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz); 
				float3 rim = pow(1.0 - saturate(dot(viewDirection, i.normalDir)), _RimStrength);


				// sample the texture
				fixed4 col = _CandyColor;
				fixed4 noise = tex2D(_NoiseTex, i.uv);

				half3 randomVectors = tex2D(_ColorNoiseTex, i.uv);

				randomVectors.x = randomVectors.x - 0.5;
				randomVectors.y = randomVectors.y - 0.5;
				randomVectors.z = randomVectors.z - 0.5;
				randomVectors = normalize(randomVectors);

				float sparkleValue = saturate((dot(viewDirection, randomVectors) - _Subtraction)*  _SparkleStrength) ;
				_SparkleColor *= sparkleValue;

				fixed4 bubble = tex2D(_BubbleTex, i.uv);
				bubble.a = bubble.r;
				bubble.a *= noise.r;

				
				
				//col.a = 1 - bubble.a;
				bubble.r = 1 - bubble.r;
				bubble.g = 1 - bubble.g;
				bubble.b = 1 - bubble.b;
				//col *= bubble;
				bubble.rgb += _Ramp;
				col.rgb *= bubble.rgb;
				col.rgb = normalize(col.rgb);
				col.a = rim;
				col.a *= _Transparency + _Transparency*bubble.a;
				col += _SparkleColor;
				
				//col.a *= (rim);
				
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
