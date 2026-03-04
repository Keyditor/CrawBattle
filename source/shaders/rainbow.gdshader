shader_type spatial;

uniform sampler2D texture_albedo : source_color;
uniform float velocidade = 1.0;

void fragment() {

	vec3 base = texture(texture_albedo, UV).rgb;

	vec3 rainbow = vec3(
		0.5 + 0.5 * sin(TIME * velocidade),
		0.5 + 0.5 * sin(TIME * velocidade + 2.094),
		0.5 + 0.5 * sin(TIME * velocidade + 4.188)
	);

	ALBEDO = base * rainbow;
}