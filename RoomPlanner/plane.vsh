#extension GL_EXT_shader_framebuffer_fetch : require
attribute vec3 position;
attribute vec2 uv_coord;

uniform mat4 mvp;
uniform vec3 color;
varying vec2 uv;
varying vec3 vertex_color;

void main(void)
{
    gl_Position =  mvp * vec4(position, 1.0);
    uv = uv_coord;
    vertex_color = color;
}
