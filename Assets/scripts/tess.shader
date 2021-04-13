Shader "Unlit/tess" 
{
    Properties {
        _Tess ("Tessellation", Range(1,32)) = 4
        _Phong ("phong", Range(0,1)) = 0.5
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _DispTex ("Disp Texture", 2D) = "gray" {}
        _NormalMap ("Normalmap", 2D) = "bump" {}
        _Displacement ("Displacement", Range(0.0005, 0.00001)) = 0.001
        _Color ("Color", color) = (1,1,1,0)
        _SpecColor ("Spec color", color) = (0.5,0.5,0.5,0.5)
        _SpecularColor ("Specular color", color) = (0.5,0.5,0.5,0.5)
        _AmbientColor("Ambient Color", Color) = (0.0,0.0,0.0,0.0)
        _RimColor("Rim Color", Color) = (0.0,0.0,0.0,0.0)
        _RimAmount("rim amount", Range(0, 5)) = 1
        _Glossiness("Glossiness", Range(0, 5)) = 1

        _NormalMapStrength("normal map strength", Range(0.0,1.0)) = 1.0
        _TextureFrequency("texture frequency", Range(0.0,20.0)) = 1.0

        _ImprintTexture ("Imprint Texture", 2D) = "white" {}

        _BackLightNormalStrength("backlighting normal strength",  Range(0.0,1.0)) = 0.5
        _BackLightPower("backlighting power",  Range(0.0,10.0)) = 1.0
        _BackLightStrength("backlighting strength",  Range(0.0,10.0)) = 1.0
        _BacklightColor("backlight Color", Color) = (0.0,0.0,0.0,0.0)
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 300
        
        CGPROGRAM
        
        #pragma surface surf Sorbet addshadow fullforwardshadows vertex:disp tessellate:tessDistance tessphong:_Phong nolightmap
        #pragma target 4.6
        #include "Tessellation.cginc"

        struct appdata {
            float4 vertex : POSITION;
            float4 tangent : TANGENT;
            float3 normal : NORMAL;
            float2 texcoord : TEXCOORD0;
        };

        float _Tess;
        float _Phong;

        float4 tessDistance (appdata v0, appdata v1, appdata v2) {
            float minDist = 15.0;
            float maxDist = 170.0;
            return UnityDistanceBasedTess(v0.vertex, v1.vertex, v2.vertex, minDist, maxDist, _Tess);
        }

        sampler2D _DispTex;
        float _Displacement;

        sampler2D _ImprintTexture;
        float4 _ImprintTexture_ST;

        float3 getNormal(float4 step, float2 uv, sampler2D heightMap, float size)
        {
            float this = tex2Dlod (heightMap, float4(float2(uv.x, uv.y),0,0)).r * size;
            float botLeft = tex2Dlod (heightMap, float4(float2(uv.x - step.x, uv.y - step.z),0,0)).r * size;
            float botRight = tex2Dlod (heightMap, float4(float2(uv.x + step.x, uv.y - step.z),0,0)).r * size;
            float topRight = tex2Dlod (heightMap, float4(float2(uv.x + step.x, uv.y + step.z),0,0)).r * size;
            float topLeft = tex2Dlod (heightMap, float4(float2(uv.x - step.x, uv.y + step.z),0,0)).r * size;

            float4 vec1 =  (float4(0, this,0,0) - float4(step.x, topRight, step.z,0));
            float4 vec2 =  (float4(0, this,0,0) - float4(step.x, botRight, -step.z,0));

            float4 vec3 =  (float4(0, this.r, 0,0) - float4(-step.x, topLeft, step.z,0));
            float4 vec4 =  (float4(0, this.r, 0,0) - float4(-step.x, botLeft, -step.z,0));

            float4 vec5 =  (float4(0, this.r, 0,0) - float4(step.x, topRight, step.z,0));
            float4 vec6 =  (float4(0, this.r, 0,0) - float4(step.x, topLeft, -step.z,0));

            float4 vec7 =  (float4(0, this.r, 0,0) - float4(-step.x, botLeft, -step.z,0));
            float4 vec8 =  (float4(0, this.r, 0,0) - float4(-step.x, botRight, step.z,0));

            float3 norm1 = normalize(cross(normalize(vec1),normalize(vec2)));
            float3 norm2 = normalize(cross(normalize(vec3),normalize(vec4)));
            float3 norm3 = normalize(cross(normalize(vec5),normalize(vec6)));
            float3 norm4 = normalize(cross(normalize(vec7),normalize(vec8)));
            return ((norm1 + norm2 + norm3 + norm4) / 4.0);
        }

        void disp (inout appdata v)
        {
            float4 height = tex2Dlod (_ImprintTexture, float4(v.texcoord.xy,0,0));
            v.vertex.xyz -= v.normal * height.r*_Displacement;
            v.vertex.xyz += (v.normal *_Displacement)/1.0;
            float4 step = 0.002;//(_MeshDimensions) / _TextureDimensions;
            float3 norm = normalize(getNormal(step, v.texcoord.xy, _ImprintTexture, 0.005));
            v.normal = (v.normal + norm)/2.0;
        }
        

        struct Input {
            float2 uv_MainTex;
            float3 worldNormal; INTERNAL_DATA
            float3 worldPos;
        };


        struct SurfaceOutputT
        {
            fixed3 Albedo;  // diffuse color
            fixed3 Normal;  // world normal, if written
            fixed3 Position;  // world position, if written
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
        
        uniform float _BackLightNormalStrength;
        uniform float _BackLightPower;
        uniform float _BackLightStrength;
        uniform fixed4 _BacklightColor;

        inline half4 LightingSorbet (SurfaceOutputT s, half3 viewDir, UnityGI gi) {
            float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
            float NdotL = saturate(dot(normalize(s.Normal) , lightDir));

            float3 H = normalize(lightDir + normalize(viewDir));
            float NdotH = dot(normalize(s.Normal), H);
            float specIntensity = saturate(pow(NdotH, s.Gloss * s.Gloss));

            float rimDot = clamp((1.0 - dot(normalize(viewDir), normalize(s.Normal))),-50.0,50.0);
            float rim = pow(rimDot, _RimAmount);

            float backLighting = pow(saturate(dot(viewDir, (-1.0 * lightDir + s.Normal * _BackLightNormalStrength))), _BackLightPower) * _BackLightStrength;

            return _AmbientColor + rim * _RimColor + specIntensity * _SpecularColor + NdotL * _Color + backLighting * _BacklightColor;
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
            o.Position = IN.worldPos;
        }
        ENDCG
    }
    FallBack "Diffuse"
}