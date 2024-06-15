shader_type spatial;


uniform vec3 skew_factors = vec3(0.1, 0.1, 0.0);
uniform float speed = 1.3;

void vertex() {
    // Calculate the distance from the origin (center of the parent node)
    float distance = length(VERTEX);

    // Use the inverse of the distance to scale the oscillation
    // Add a small value to avoid division by zero
    float scale = 2.0 / (distance + 0.1);

    float oscillation_x = sin(TIME * speed) * skew_factors.x * scale;
    float oscillation_y = cos(TIME * speed) * skew_factors.y * scale * 1.05;
    float oscillation_z = sin(TIME * speed) * skew_factors.z * scale * 1.1;

    VERTEX.x += VERTEX.y * oscillation_x;
    VERTEX.y += VERTEX.z * oscillation_y;
    VERTEX.z += VERTEX.x * oscillation_z;
}

void fragment() {
    // Calculate the interpolation factor based on the vertical position

    // Define the colors
    vec4 color = vec4(0.165, 0.604, 0.014, 1.0); 

    // Set the fragment color
    ALBEDO = color.rgb;
    //ALPHA = color.a;
    // Called for every pixel the material is visible on.
}

//void light() {
    // Called for every pixel for every light affecting the material.
    // Uncomment to replace the default light processing function with this one.
//}
