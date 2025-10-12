shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_nearest;

const mat3 contrastMatrix = 
mat3(
	vec3(2.0, 0, 0),
	vec3(0, 2.0, 0),
	vec3(0, 0, 2.0));

void fragment() {
	// Called for every pixel the material is visible on.
	vec3 Texture = texture(screen_texture, SCREEN_UV).rgb;
	Texture.rgb = mix(vec3(0.5), Texture.rgb, 1.9);
	COLOR.rgb =  Texture;
}