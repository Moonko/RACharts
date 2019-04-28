precision mediump float;

attribute vec4 a_position;
uniform mat4 uMatrix;

void main() {
    gl_Position = uMatrix * a_position;
}
