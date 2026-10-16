shader_type canvas_item;

// Water Caustics & Refractive Optical Distortion Shader
// Simulates dynamic sunlight refraction webs and gentle underwater shimmer.

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform vec4 water_tint : source_color = vec4(0.06, 0.28, 0.38, 0.28);
uniform vec4 caustic_color : source_color = vec4(0.35, 0.88, 0.95, 0.40);
uniform float caustic_scale : hint_range(0.001, 0.05) = 0.006;
uniform float caustic_speed : hint_range(0.1, 5.0) = 0.75;
uniform float distortion_strength : hint_range(0.0, 0.05) = 0.004;

float caustic_pattern(vec2 uv, float time) {
	vec2 p = uv;

	vec2 w1 = vec2(sin(p.x * 1.6 + time * 0.7), cos(p.y * 1.3 - time * 0.8));
	vec2 w2 = vec2(cos(p.x * 2.1 - time * 0.9), sin(p.y * 2.4 + time * 0.6));
	vec2 w3 = vec2(sin((p.x + p.y) * 1.8 + time * 1.1), cos((p.x - p.y) * 1.7 - time * 0.9));

	vec2 warped = p + (w1 + w2 + w3) * 0.16;

	float f1 = sin(warped.x * 3.0) * sin(warped.y * 3.0);
	float f2 = sin(warped.x * 6.0 + time * 0.4) * sin(warped.y * 6.0 - time * 0.4);

	return pow(abs(f1 + f2 * 0.5), 1.6);
}

varying vec2 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	float time = TIME * caustic_speed;

	// 1. Refractive wave distortion on objects beneath water surface
	vec2 wave_offset = vec2(
		sin(world_pos.y * 0.02 + time * 1.2),
		cos(world_pos.x * 0.02 + time * 1.0)
	) * distortion_strength;

	vec4 background = texture(screen_texture, SCREEN_UV + wave_offset);

	// 2. Animated caustic interference network
	float c1 = caustic_pattern(world_pos * caustic_scale, time);
	float c2 = caustic_pattern((world_pos + vec2(140.0, 80.0)) * caustic_scale * 1.35, time * 1.2);
	float caustic_intensity = clamp((c1 * 0.65 + c2 * 0.35), 0.0, 1.0);

	// 3. Composite underwater lighting
	vec4 result = mix(background, water_tint, water_tint.a);
	result = mix(result, caustic_color, caustic_intensity * caustic_color.a);

	COLOR = result;
}
