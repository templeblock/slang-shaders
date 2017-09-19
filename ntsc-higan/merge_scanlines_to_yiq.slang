#version 450

#pragma name MergedScanlines

layout(push_constant) uniform Push
{
	mat4 MVP;
} registers;

#pragma stage vertex
layout(location = 0) in vec4 Position;
layout(location = 1) in vec2 TexCoord;
layout(location = 0) out vec2 vTexCoord;

void main()
{
	gl_Position = registers.MVP * Position;
	vTexCoord = TexCoord;
}

#pragma stage fragment
layout(location = 0) in vec2 vTexCoord;
layout(location = 0) out vec3 FragColor;
layout(set = 0, binding = 0) uniform sampler2D Source;

const mat3 yiq_mat = mat3(
	0.2989, 0.5959, 0.2115,
	0.5870, -0.2744, -0.5229,
	0.1140, -0.3216, 0.3114);

void main()
{
	vec3 yiq = yiq_mat * textureLod(Source, vTexCoord, 0.0).rgb;
	yiq.yz = yiq.yz * 0.5 + 0.5;
	FragColor = yiq;
}
