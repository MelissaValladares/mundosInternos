shader_type spatial;
render_mode depth_draw_opaque, unshaded, world_vertex_coords;

uniform vec4 albedo : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D texture_albedo : source_color,filter_linear_mipmap,repeat_enable;

uniform float normal_offset : hint_range(0, 1, 0.01) = 0.02;
uniform float time_influence : hint_range(0, 50) = 3;
uniform float y_div : hint_range(0, 10, .1) = 2.87;

void vertex() {
    VERTEX.x += sin(VERTEX.y * y_div + round(TIME * time_influence)) * normal_offset;
    VERTEX.y += sin(VERTEX.x * y_div + round(TIME * time_influence)) * normal_offset;
    VERTEX.z += sin(VERTEX.y * y_div + round(TIME * time_influence)) * normal_offset;
}

void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo, base_uv);
	albedo_tex *= COLOR;
	ALBEDO = albedo.rgb * albedo_tex.rgb;
}