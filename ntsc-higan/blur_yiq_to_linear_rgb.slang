#version 450
#pragma name LinearRGB

layout(push_constant) uniform UBO
{
    mat4 MVP;
} global;

#pragma stage vertex
layout(location = 0) in vec4 Position;
layout(location = 1) in vec2 TexCoord;
layout(location = 0) out vec2 vTexCoord;

void main()
{
    gl_Position = global.MVP * Position;
    vTexCoord = TexCoord;
}

#pragma stage fragment
#pragma format R8G8B8A8_SRGB
layout(location = 0) in vec2 vTexCoord;
layout(location = 0) out vec3 FragColor;
layout(set = 0, binding = 1) uniform sampler2D MergedScanlines;

#define HORIZ_GAUSS_WIDTH_LUMA 1.0
#define HORIZ_GAUSS_WIDTH_CHROMA 2.0

const mat3 yiq2rgb_mat = mat3(
	1.0, 1.0, 1.0,
	0.956, -0.2720, -1.1060,
	0.6210, -0.6474, 1.7046);

vec3 upk(vec3 yiq)
{
	return vec3(yiq.x, yiq.yz * 2.0 - 1.0);
}

void main()
{
	float luma = 0.0;
	vec2 chroma = vec2(0.0);
	float w_luma = 0.0;
	float w_chroma = 0.0;

#define B(off, WL, WC) { \
		vec3 yiq = upk(textureLodOffset(MergedScanlines, vTexCoord, 0.0, ivec2(off, 0)).xyz); \
        const float g_luma = exp(-0.5 * float(off) * float(off) / (WL * WL)); \
        const float g_chroma = exp(-0.5 * float(off) * float(off) / (WC * WC)); \
        luma += g_luma * yiq.x; \
        chroma += g_chroma * yiq.yz; \
		w_luma += g_luma; \
		w_chroma += g_chroma; \
    }
	B(-4, HORIZ_GAUSS_WIDTH_LUMA, HORIZ_GAUSS_WIDTH_CHROMA)
	B(-3, HORIZ_GAUSS_WIDTH_LUMA, HORIZ_GAUSS_WIDTH_CHROMA)
	B(-2, HORIZ_GAUSS_WIDTH_LUMA, HORIZ_GAUSS_WIDTH_CHROMA)
	B(-1, HORIZ_GAUSS_WIDTH_LUMA, HORIZ_GAUSS_WIDTH_CHROMA)
	B(0, HORIZ_GAUSS_WIDTH_LUMA, HORIZ_GAUSS_WIDTH_CHROMA)
	B(+1, HORIZ_GAUSS_WIDTH_LUMA, HORIZ_GAUSS_WIDTH_CHROMA)
	B(+2, HORIZ_GAUSS_WIDTH_LUMA, HORIZ_GAUSS_WIDTH_CHROMA)
	B(+3, HORIZ_GAUSS_WIDTH_LUMA, HORIZ_GAUSS_WIDTH_CHROMA)
	B(+4, HORIZ_GAUSS_WIDTH_LUMA, HORIZ_GAUSS_WIDTH_CHROMA)

	luma /= w_luma;
	chroma /= w_chroma;

	vec3 rgb = clamp(yiq2rgb_mat * vec3(luma, chroma), vec3(0.0), vec3(1.0));

	rgb = pow(rgb, vec3(2.4));
    FragColor = rgb;
}
