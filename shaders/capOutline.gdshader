shader_type spatial;
render_mode unshaded, cull_front;

void vertex() {
    VERTEX += NORMAL * 0.02;
}

void fragment() {
    ALBEDO = vec3(0.0, 0.0, 0.0);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
