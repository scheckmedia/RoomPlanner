attribute vec3 position;
attribute vec4 colors;

uniform mat4 mvp;
varying vec4 color;

void main(void)
{
    gl_PointSize = 20.0;
    gl_Position = mvp * vec4(position, 1.0);
    color = vec4(0,1,0,1);
}
