// Define the shader type as spatial, meaning it's used for 3D rendering.
shader_type spatial;

// Set the render mode to unshaded, which means the shader will not be affected by lighting.
render_mode unshaded;

// Uniform sampler for the screen texture. This texture will be used for sampling the screen's content.
uniform sampler2D SCREEN_TEXTURE: repeat_disable, hint_screen_texture;

// Uniform sampler for the depth texture. This texture contains depth information for each pixel.
uniform sampler2D DEPTH_TEXTURE: hint_depth_texture, filter_linear_mipmap;

// Uniform variable for controlling the stroke size. The hint_range specifies the min, max, and step values.
uniform float StrokeSize: hint_range(0.0, 32.0, 0.001) = 3.5;

// Uniform variable for controlling the base depth mask value.
uniform float DepthMaskBase: hint_range(0.0, 2.0, 0.001) = 0.05;

// Uniform variable for controlling the intensity of the depth mask effect.
uniform float DepthMaskIntensity: hint_range(-128.0, 128.0, 0.001) = 0.3;

// Constant values used for offset calculations in the shader.
const float _offsetA = 0.0002;
const float _offsetB = 0.0003;
const float _offsetC = 0.0004;

// Vertex shader function. It sets the position of each vertex.
void vertex() {
  POSITION = vec4(VERTEX, 1.0);  // Set the position of the vertex in 4D space.
}

// Function to find the brightest color around a given UV coordinate.
vec3 find_brightest(vec2 _uv) {
    float brightest_value = 0.0;  // Variable to keep track of the brightest value found.
    vec3 brightest_color = vec3(0.0);  // Variable to keep track of the brightest color found.

    // Array to hold colors sampled from different offsets around the given UV coordinate.
    vec3 sample_colors[7] = vec3[](
        texture(SCREEN_TEXTURE, _uv).rgb,  // Sample color at the original UV coordinate.
        texture(SCREEN_TEXTURE, vec2(_uv.x, _uv.y + _offsetC * StrokeSize)).rgb,  // Sample color with vertical offset.
        texture(SCREEN_TEXTURE, vec2(_uv.x - _offsetB * StrokeSize, _uv.y + _offsetA * StrokeSize)).rgb,  // Sample color with diagonal offset.
        texture(SCREEN_TEXTURE, vec2(_uv.x - _offsetB * StrokeSize, _uv.y - _offsetA * StrokeSize)).rgb,  // Sample color with opposite diagonal offset.
        texture(SCREEN_TEXTURE, vec2(_uv.x, _uv.y - _offsetC * StrokeSize)).rgb,  // Sample color with vertical offset in the opposite direction.
        texture(SCREEN_TEXTURE, vec2(_uv.x + _offsetB * StrokeSize, _uv.y - _offsetA * StrokeSize)).rgb,  // Sample color with diagonal offset in the opposite direction.
        texture(SCREEN_TEXTURE, vec2(_uv.x + _offsetB * StrokeSize, _uv.y + _offsetA * StrokeSize)).rgb   // Sample color with diagonal offset.
    );

    // Loop through the sampled colors to find the brightest one.
    for (int i = 0; i < 7; i++) {
        float brightness = max(max(sample_colors[i].r, sample_colors[i].g), sample_colors[i].b);  // Compute brightness from RGB components.
        if (brightness > brightest_value) {
            brightest_value = brightness;  // Update the brightest value found.
            brightest_color = sample_colors[i];  // Update the brightest color found.
        }
    }
    return brightest_color;  // Return the brightest color.
}

// Fragment shader function. It processes each pixel on the screen.
void fragment() {
    float depth = texture(DEPTH_TEXTURE, SCREEN_UV).r;  // Sample the depth value from the depth texture.
    depth = PROJECTION_MATRIX[3][2] / (depth + PROJECTION_MATRIX[2][2]);  // Compute the corrected depth value.
    float mask = (depth * DepthMaskBase);  // Compute the depth mask value based on the base depth mask.
    vec4 modified_mask = vec4(pow(mask, DepthMaskIntensity));  // Apply intensity to the depth mask using power function.
    modified_mask = clamp(modified_mask, 0.0, 1.0);  // Clamp the mask value to the range [0.0, 1.0].
    vec3 base_color = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;  // Sample the base color from the screen texture.
    ALBEDO = mix(base_color, find_brightest(SCREEN_UV), modified_mask.rgb).rgb;  // Mix the base color with the brightest color based on the depth mask.
    // Uncomment the following line to see the depth mask as the output color.
    //ALBEDO = modified_mask.rgb;
}
