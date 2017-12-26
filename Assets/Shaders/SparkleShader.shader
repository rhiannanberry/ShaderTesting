﻿// Upgrade NOTE: upgraded instancing buffer 'Props' to new syntax.

Shader "Custom/Sparkle" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_GradientColorA("Gradient Color A", Color) = (1,1,1,1)
		_GradientColorB("Gradient Color B", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_NoiseTex("Seed", 2D) = "white" {}
		_Blend("Blend", Range(0, 1)) = 0.5
		_Subtraction("Subtraction", Range(0,1)) = 0.5
		_SparkleStrength("Sparkle Strength", Range(0,10)) = 1
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _NoiseTex;

		struct Input {
			float2 uv_MainTex;
			float3 viewDir;
			float3 worldPos;
		};

		fixed4 _Color;
		fixed4 _GradientColorA;
		fixed4 _GradientColorB;
		float _Blend;
		float _SparkleStrength;
		float _Subtraction;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		void surf (Input IN, inout SurfaceOutputStandard o) {
			float3 localPos = IN.worldPos - mul(unity_ObjectToWorld, float4(0, 0, 0, 1)).xyz;
			half3 randomVectors = tex2D(_NoiseTex, IN.uv_MainTex);
			
			randomVectors.x = randomVectors.x - 0.5;
			randomVectors.y = randomVectors.y - 0.5;
			randomVectors.z = randomVectors.z - 0.5;

			randomVectors = normalize(randomVectors);

			float sparkleValue = saturate((dot(normalize(IN.viewDir), randomVectors) - _Subtraction) *  _SparkleStrength);
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = lerp(_GradientColorA, _GradientColorB, localPos.y);
			// Metallic and smoothness come from slider variables
			//o.Metallic = _Metallic;
			//o.Smoothness = _Glossiness;
			o.Emission += sparkleValue * _Color;
			//o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
