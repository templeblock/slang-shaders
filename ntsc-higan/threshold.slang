#version 450

layout(push_constant) uniform Push
{
    float GLOW_BOOST;
} param;

#pragma parameter GLOW_BOOST "Glow Boost" 0.15 0.05 0.5 0.05

layout(std140, set = 0, binding = 0) uniform UBO
{
    mat4 MVP;
    vec4 OutputSize;
    vec4 OriginalSize;
    vec4 SourceSize;
} global;

#pragma stage vertex
layout(location = 0) in  vec4  Position;
layout(location = 1) in  vec2  TexCoord;
layout(location = 0) out vec2  vTexCoord;

void main()
{
    gl_Position = global.MVP * Position;
    vTexCoord   = TexCoord;
}

#pragma stage fragment
#pragma format R8G8B8A8_SRGB
layout(location = 0) in  vec2  vTexCoord;
layout(location = 0) out vec4  FragColor;
layout(set = 0, binding = 2) uniform sampler2D Source;

void main()
{
	vec3 rgb = textureLod(Source, vTexCoord, 0.0).rgb;
	float luma = dot(rgb, vec3(0.29, 0.60, 0.11));
	float passed_luma = clamp((1.0 + param.GLOW_BOOST) * luma - 1.0, 0.0, 1.0);
    vec3 color  = passed_luma * rgb;
    FragColor = vec4(6.0 * color, 1.0);
}
