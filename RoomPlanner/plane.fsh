#extension GL_EXT_shader_framebuffer_fetch : require
varying lowp vec2 uv;
uniform sampler2D tex;

void main(void)
{
    lowp vec2 flipped = vec2(uv.x, 1.0 - uv.y);
    gl_FragColor = texture2D(tex, flipped);
}
