attribute vec3 position;
attribute vec4 colors;

uniform mat4 mvp;
varying vec4 color;

void main(void)
{
    gl_PointSize = 2.0;
    gl_Position = mvp * vec4(position, 1.0);
    color = colors;
}
