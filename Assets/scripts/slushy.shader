    Shader "Unlit/slushy"
{
    Properties
    {
        [HDR]
        _Color ("Color", Color) = (0.0,0.0,0.0,0.0)
        _AmbientColor("Ambient Color", Color) = (0.0,0.0,0.0,0.0)
        _AmbientAmount("Ambient amount", Range(0.0,1.0)) = 0.0
        _SpecularColor("Specular Color", Color) = (0.0,0.0,0.0,1)
        _RimColor("rim Color", Color) = (0.0,0.0,0.0,1)
        _UnderColor("Under Color", Color) = (0.0,0.0,0.0,1)
        _Glossiness("Glossiness", Range(0, 5)) = 1
        _BackLightingNormalAmount("Back lighting", Range(0.0,1.0)) = 0.5
        _RimAmount("rim amount", Range(0.0,20.0)) = 1.0
        _Power("power", Range(0.0,5.0)) = 1
        _Scale("scale", Range(0.0,5.0)) = 1
        _Bumps("bumps", Range(0.0,1.0)) = 0.5

        _UseNormalMap("use normal map", int) = 1
        _NormalMapAmount("Normal map amount", range(0.0,1.0)) = 1.0
        _NormalMap ("Texture", 2D) = "white" {}

        _ImprintTexture ("Imprint Texture", 2D) = "white" {}
        _MeshDimensions ("Mesh Dimensions", Vector) = (0.0,0.0,0.0,0.0)
        _TextureDimensions ("Texture Dimensions", Vector) = (0.0,0.0,0.0,0.0)
    }
    SubShader
    {
        Tags { "LightMode"="ForwardBase" }
        LOD 300

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "UnityLightingCommon.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 wNormal : NORMAL;
                float3 wpos : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
                half3 tspace0 : TEXCOORD3; // tangent.x, bitangent.x, normal.x
                half3 tspace1 : TEXCOORD4; // tangent.y, bitangent.y, normal.y
                half3 tspace2 : TEXCOORD5; // tangent.z, bitangent.z, normal.z
                float2 uv2 : TEXCOORD6;
                float3 customerDat : TEXCOORD7;
            };

            uniform float4 _Color;
            uniform float _Glossiness;
            uniform float4 _SpecularColor;
            uniform float4 _RimColor;
            uniform float4 _UnderColor;
            uniform float4 _AmbientColor;
            uniform float _AmbientAmount;
            uniform float _RimAmount;
            uniform float _BackLightingNormalAmount;
            uniform float _Power;
            uniform float _Scale;
            uniform float _Bumps;

            uniform int _UseNormalMap;
            uniform float _NormalMapAmount;
            sampler2D _NormalMap;
            float4 _NormalMap_ST;

            sampler2D _ImprintTexture;
            float4 _ImprintTexture_ST;
            uniform float4 _MeshDimensions;
            uniform float4 _TextureDimensions;

            float3 getNormal(float4 step, float2 uv, sampler2D heightMap, float size){
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
            };

            v2f vert (appdata_tan v)
            {
                v2f o;

                o.uv2 = TRANSFORM_TEX(v.texcoord, _ImprintTexture);
                float4 height = tex2Dlod (_ImprintTexture, float4(float2(o.uv2.x, o.uv2.y),0,0));
                v.vertex.z -= height.r/5000.0;

                float4 step = 0.01;//(_MeshDimensions) / _TextureDimensions;
                float3 norm = normalize(getNormal(step, o.uv2, _ImprintTexture, 0.01));

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.wpos = mul(unity_ObjectToWorld, v.vertex);
                o.wNormal = (UnityObjectToWorldNormal(v.normal) + normalize(norm))/2.0;
                o.viewDir = WorldSpaceViewDir(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _NormalMap);

                half3 wTangent = UnityObjectToWorldDir(v.tangent.xyz);
                // compute bitangent from cross product of normal and tangent
                half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
                half3 wBitangent = cross(o.wNormal, wTangent) * tangentSign;
                // output the tangent space matrix
                o.tspace0 = half3(wTangent.x, wBitangent.x, o.wNormal.x);
                o.tspace1 = half3(wTangent.y, wBitangent.y, o.wNormal.y);
                o.tspace2 = half3(wTangent.z, wBitangent.z, o.wNormal.z);

                o.customerDat = float3(height.r, height.r, height.r);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                half2 uv_NormalMap = TRANSFORM_TEX (i.uv, _NormalMap);

                half3 tnormal = UnpackNormal(tex2D(_NormalMap, uv_NormalMap * 8.0));
                 // transform normal from tangent to world space
                half3 worldNormal;
                worldNormal.x = dot(i.tspace0, tnormal);
                worldNormal.y = dot(i.tspace1, tnormal);
                worldNormal.z = dot(i.tspace2, tnormal);

                //check if we should disabled normal mapping
                if (!_UseNormalMap){
                    worldNormal = i.wNormal;
                }

                worldNormal = (i.wNormal + (worldNormal*_NormalMapAmount))/2.0;

                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float NdotL = saturate(dot(normalize(worldNormal) , lightDir));

                float3 H = normalize(lightDir + normalize(i.viewDir));
                float NdotH = dot(normalize(worldNormal), H);
                float specIntensity = saturate(pow(NdotH, _Glossiness * _Glossiness));

                float rimDot = clamp((1.0 - dot(normalize(i.viewDir), normalize(i.wNormal))),-50.0,50.0);
                float rim = pow(rimDot,_RimAmount);

                float3 FragToLight = lightDir;

                float3 HB = FragToLight + worldNormal * _BackLightingNormalAmount;

                float backLighting = pow(saturate(dot(normalize(i.viewDir), -normalize(HB))), _Power) * _Scale;

                float bumps = tex2D(_NormalMap, uv_NormalMap);
                if (bumps < _Bumps) {
                    bumps = 0;
                }

                float4 imprint = tex2D(_ImprintTexture, i.uv2);

                float4 shading = _AmbientAmount * _AmbientColor + _LightColor0 * backLighting * _Color + _Color * NdotL + specIntensity * _SpecularColor + rim * _RimColor;

                // shading += _UnderColor * i.customerDat.r;
                return shading;// - imprint*2.0;
            }
            ENDCG
        }
    }
}
