precision mediump float;
uniform sampler2D tex;
uniform sampler2D normal;
varying vec2 vTextureCoord;
varying float vAlpha;

uniform vec3 lightPos;
uniform vec4 lightColor;      //light RGBA -- alpha is intensity
uniform vec2 resolution;      //resolution of screen need to know the position of the pixel
uniform vec4 ambientColor;    //ambient RGBA -- alpha is intensity
uniform vec3 falloff;

uniform vec3 lightPos2;
uniform vec4 lightColor2;      //light RGBA -- alpha is intensity
uniform vec2 resolution2;      //resolution of screen need to know the position of the pixel
uniform vec4 ambientColor2;
uniform vec3 falloff2;



void kore(void)
{
    //vec3 texNormal =  texture2D (uNormals, vTexCoord).rgb;
    //vec4 texColor =  texture2D (uColors, vTexCoord).rgba;
    vec3 texNormal =  texture2D (normal, vTextureCoord).rgb;
    vec4 texColor =  texture2D (tex, vTextureCoord).rgba;

    texColor = texColor * vAlpha;

    vec3 lightDir = vec3(lightPos.x / resolution.x, 1.0 - (lightPos.y / resolution.y), lightPos.z);
    lightDir = vec3(lightDir.xy - (gl_FragCoord.xy / resolution.xy), lightDir.z);

    lightDir.x *= resolution.x / resolution.y;

    float D = length(lightDir);

    vec3 N = normalize(texNormal * 2.0 - 1.0);
    vec3 L = normalize(lightDir);

    vec3 diffuse = (lightColor.rgb * lightColor.a) * max(dot(N, L), 0.0);
    vec3 ambient = ambientColor.rgb * ambientColor.a;
    float attenuation = 1.0 / ( falloff.x + (falloff.y*D) + (falloff.z*D*D) );

    vec3 intensity = ambient + diffuse * attenuation;
    ///////////
    vec3 lightDir2 = vec3(lightPos2.x / resolution.x, 1.0 - (lightPos2.y / resolution.y), lightPos2.z);
    lightDir2 = vec3(lightDir2.xy - (gl_FragCoord.xy / resolution.xy), lightDir2.z);

    lightDir2.x *= resolution.x / resolution.y;

    float D2 = length(lightDir2);

    vec3 N2 = normalize(texNormal * 2.0 - 1.0);
    vec3 L2 = normalize(lightDir2);

    vec3 diffuse2 = (lightColor2.rgb * lightColor2.a) * max(dot(N2, L2), 0.0);
    vec3 ambient2 = ambientColor2.rgb * ambientColor2.a;
    float attenuation2 = 1.0 / ( falloff2.x + (falloff2.y*D2) + (falloff2.z*D2*D2) );

    vec3 intensity2 = ambient2 + diffuse2 * attenuation2;

    ///////////
    //vec3 finalColor = texColor.rgb * max(intensity,intensity2);
    vec3 finalColor = texColor.rgb * (intensity+intensity2);
  
    gl_FragColor = vec4(finalColor, texColor.a);
}
