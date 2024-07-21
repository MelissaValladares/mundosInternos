shader_type spatial;

render_mode unshaded;

uniform vec4 color : hint_color;
uniform float edge_smoothness : hint_range(0.0, 1.0) = 0.5;

void fragment() {
    vec2 uv = FRAGCOORD.xy / SCREEN_PIXEL_SIZE.xy;
    vec2 dxy = fwidth(uv);
    vec2 smooth_uv = smoothstep(uv - dxy * edge_smoothness, uv + dxy * edge_smoothness, uv);

    vec4 final_color = color;
    final_color.a *= smooth_uv.x * smooth_uv.y;

    COLOR = final_color;
}
