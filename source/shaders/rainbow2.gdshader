shader_type spatial;

uniform float intensidade = 2.0;
uniform float velocidade = 0.0;

void fragment() {
	vec3 view_dir = normalize(-VIEW);
	float fresnel = pow(1.0 - dot(NORMAL, view_dir), intensidade);

	float cor_shift = fresnel + TIME * velocidade;

	vec3 cor = vec3(
		sin(cor_shift * 3.0) * 0.5 + 0.5,
		sin(cor_shift * 3.0 + 2.0) * 0.5 + 0.5,
		sin(cor_shift * 3.0 + 4.0) * 0.5 + 0.5
	);

	ALBEDO = cor;
	METALLIC = 0.9;
	ROUGHNESS = 0.15;
	CLEARCOAT = 1.0;
}