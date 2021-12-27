shader_type canvas_item;
render_mode unshaded;
uniform vec4 color : hint_color;
uniform int blurSize : hint_range(0,20);

void fragment() {
	COLOR = texture(TEXTURE, UV); 
	COLOR.xyz += color.xyz;
	COLOR = textureLod(SCREEN_TEXTURE, SCREEN_UV, float(blurSize)/10.0); 
}