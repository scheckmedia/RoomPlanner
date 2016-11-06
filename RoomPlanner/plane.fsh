#extension GL_EXT_shader_framebuffer_fetch : require
varying lowp vec2 uv;
uniform sampler2D tex;

void main(void)
{
    lowp vec2 flipped = vec2(1.0 - uv.x, 1.0 - uv.y);
    gl_FragColor = vec4(0.3,0.3,0.3, 1.0);
}
