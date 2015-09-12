attribute vec3 pos;

uniform mat4 viewproj;

void kore() {
	gl_Position = viewproj*vec4(pos,1.0);
}
