shader_type spatial;
render_mode unshaded, blend_add;

uniform float progress : hint_range(0.0,1.0);
uniform float line_size = 0.02;
uniform float trail_size = 0.15;

uniform float wave_strength = 0.02;
uniform float wave_frequency = 10.0;
uniform float wave_speed = 3.0;

uniform vec4 line_color : source_color = vec4(1.0,1.0,1.0,1.0);
uniform vec4 trail_color : source_color = vec4(0.2,0.6,1.0,1.0);

void fragment() {

	float wave = sin(UV.x * wave_frequency + TIME * wave_speed) * wave_strength;

	float y = UV.y + wave;

	float line = smoothstep(progress - line_size, progress, y)
	           - smoothstep(progress, progress + line_size, y);

	float trail = smoothstep(progress - trail_size, progress, y);

	vec3 col = line_color.rgb * line + trail_color.rgb * trail * 0.5;
	float alpha = line * line_color.a + trail * trail_color.a * 0.5;

	ALBEDO = col;
	ALPHA = alpha;
}