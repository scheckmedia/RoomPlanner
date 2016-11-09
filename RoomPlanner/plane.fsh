#extension GL_EXT_shader_framebuffer_fetch : require
varying lowp vec2 uv;
varying lowp vec3 vertex_color;
uniform sampler2D tex;

void main(void)
{
    lowp vec2 flipped = vec2(uv.x, 1.0 - uv.y);
    //gl_FragColor = vec4(vertex_color.r, vertex_color.g, vertex_color.b, 1.0);
    gl_FragColor = texture2D(tex, flipped);
}
