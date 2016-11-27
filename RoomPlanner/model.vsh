attribute vec3 position;
attribute vec2 uv_coord;
attribute vec3 normals;

uniform mat4 model_view;
uniform mat4 projection;
uniform mat4 normal_matrix;

varying vec2 uv;
varying vec3 normal_pos;
varying vec3 vertex_pos;


void main(void)
{
    gl_Position = projection * model_view * vec4(position, 1.0);
    gl_PointSize = 10.0;
    uv = uv_coord;
    
    vec4 pos = model_view * vec4(position, 1.0);
    vertex_pos = vec3(pos) / pos.w;
    normal_pos = vec3(normal_matrix * vec4(normals, 0.0));
}
