Shader "Unlit/tess" 
{
    Properties {
        _Tess ("Tessellation", Range(1,32)) = 4
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _DispTex ("Disp Texture", 2D) = "gray" {}
        _NormalMap ("Normalmap", 2D) = "bump" {}
        _Displacement ("Displacement", Range(0, 1.0)) = 0.3
        _Color ("Color", color) = (1,1,1,0)
        _SpecColor ("Spec color", color) = (0.5,0.5,0.5,0.5)
        _SpecularColor ("Specular color", color) = (0.5,0.5,0.5,0.5)
        _AmbientColor("Ambient Color", Color) = (0.0,0.0,0.0,0.0)
        _RimColor("Rim Color", Color) = (0.0,0.0,0.0,0.0)
        _RimAmount("rim amount", Range(0, 5)) = 1
        _Glossiness("Glossiness", Range(0, 5)) = 1

        _NormalMapStrength("normal map strength", Range(0.0,1.0)) = 1.0
        _TextureFrequency("texture frequency", Range(0.0,20.0)) = 1.0
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 300
        
        CGPROGRAM
        
        #pragma surface surf Sorbet addshadow fullforwardshadows vertex:disp tessellate:tessFixed nolightmap
        #pragma target 4.6

        struct appdata {
            float4 vertex : POSITION;
            float4 tangent : TANGENT;
            float3 normal : NORMAL;
            float2 texcoord : TEXCOORD0;
        };

        float _Tess;

        float4 tessFixed()
        {
            return _Tess;
        }

        sampler2D _DispTex;
        float _Displacement;

        void disp (inout appdata v)
        {
            float d = tex2Dlod(_DispTex, float4(v.texcoord.xy,0,0)).r * _Displacement;
            v.vertex.xyz += v.normal * d;
        }

        struct Input {
            float2 uv_MainTex;
            float3 worldNormal; INTERNAL_DATA
        };


        struct SurfaceOutputT
        {
            fixed3 Albedo;  // diffuse color
            fixed3 Normal;  // tangent space normal, if written
            fixed3 Emission;
            fixed3 Ambience;
            half Specular;  // specular power in 0..1 range
            fixed Gloss;    // specular intensity
            fixed Alpha;    // alpha for transparencies
        };
        
        sampler2D _MainTex;
        sampler2D _NormalMap;
        uniform fixed4 _Color;
        uniform fixed4 _AmbientColor;
        uniform fixed4 _SpecularColor;
        uniform fixed4 _RimColor;
        uniform float _RimAmount;
        uniform float _Glossiness;

        uniform float _NormalMapStrength;
        uniform float _TextureFrequency;

        inline half4 LightingSorbet (SurfaceOutputT s, half3 viewDir, UnityGI gi) {
            float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
            float NdotL = saturate(dot(normalize(s.Normal) , lightDir));

            float3 H = normalize(lightDir + normalize(viewDir));
            float NdotH = dot(normalize(s.Normal), H);
            float specIntensity = saturate(pow(NdotH, s.Gloss * s.Gloss));

            float rimDot = clamp((1.0 - dot(normalize(viewDir), normalize(s.Normal))),-50.0,50.0);
            float rim = pow(rimDot, _RimAmount);

            return _AmbientColor + rim * _RimColor + specIntensity * _SpecularColor + NdotL * _Color;
        }

        inline void LightingSorbet_GI (SurfaceOutputT s, UnityGIInput data, inout UnityGI gi){
            
        }

        void surf (Input IN, inout SurfaceOutputT o) {
            half4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Gloss = _Glossiness;
            o.Ambience = float3(_AmbientColor.r, _AmbientColor.g, _AmbientColor.b);
            float3 nmNormal = UnpackNormal(tex2D(_NormalMap, IN.uv_MainTex * _TextureFrequency));
            WorldNormalVector (IN, o.Normal);
            o.Normal += nmNormal * _NormalMapStrength;
        }
        ENDCG
    }
    FallBack "Diffuse"
}