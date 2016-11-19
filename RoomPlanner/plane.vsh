attribute vec3 position;
attribute vec2 uv_coord;

uniform mat4 mvp;
varying vec2 uv;

void main(void)
{
    gl_Position = mvp * vec4(position, 1.0);
    uv = uv_coord;
}
