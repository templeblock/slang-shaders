#version 450

layout(push_constant) uniform UBO
{
    mat4 MVP;
    vec4 OutputSize;
    vec4 OriginalSize;
    vec4 SourceSize;
} global;

#pragma stage vertex
layout(location = 0) in  vec4 Position;
layout(location = 1) in  vec2 TexCoord;
layout(location = 0) out vec2 vTexCoord;

void main()
{
    gl_Position = global.MVP * Position;
    vTexCoord   = TexCoord;
}

#pragma stage fragment
#pragma format R16G16B16A16_SFLOAT
layout(set = 0, binding = 0) uniform sampler2D Source;
layout(location = 0) in highp vec2 vUV;
layout(location = 0) out vec4 FragColor;

void main()
{
    vec4 value = 0.25 * textureLod(Source, vUV, 0.0);
    value += 0.0625 * textureLod(Source, vUV + vec2(-1.75, +1.75) * global.SourceSize.z, 0.0);
    value += 0.125 * textureLod(Source, vUV + vec2(+0.00, +1.75) * global.SourceSize.z, 0.0);
    value += 0.0625 * textureLod(Source, vUV + vec2(+1.75, +1.75) * global.SourceSize.z, 0.0);
    value += 0.125 * textureLod(Source, vUV + vec2(-1.75, +0.00) * global.SourceSize.z, 0.0);
    value += 0.125 * textureLod(Source, vUV + vec2(+1.75, +0.00) * global.SourceSize.z, 0.0);
    value += 0.0625 * textureLod(Source, vUV + vec2(-1.75, -1.75) * global.SourceSize.z, 0.0);
    value += 0.125 * textureLod(Source, vUV + vec2(+0.00, -1.75) * global.SourceSize.z, 0.0);
    value += 0.0625 * textureLod(Source, vUV + vec2(+1.75, -1.75) * global.SourceSize.z, 0.0);

    FragColor = value;
}
