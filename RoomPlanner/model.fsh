precision mediump float;

varying vec2 uv;
uniform sampler2D tex;

varying vec3 normal_pos;
varying vec3 vertex_pos;

const vec3 light_pos = vec3(0.0,1.0,0.0);
const vec3 ambient_color = vec3(0.1, 0.1, 0.1);
const vec3 diffuse_color = vec3(0.0, 0.0, 0.0);
const vec3 spec_color = vec3(1.0, 1.0, 1.0);
const float shininess = 16.0;
const float screen_gamma = 2.2;

void main(void)
{
    vec2 flipped = vec2(uv.x, 1.0 - uv.y);
    vec4 tex_color = texture2D(tex, flipped);
    
    vec3 normal = normalize(normal_pos);
    vec3 light_dir = normalize(light_pos - vertex_pos);
    
    float lambertian = max(dot(light_dir,normal), 0.0);
    float specular = 0.0;
    
    if(lambertian > 0.0) {
        
        vec3 view_dir = normalize(-vertex_pos);
        
        // this is blinn phong
        vec3 half_dir = normalize(light_dir + view_dir);
        float spec_angle = max(dot(half_dir, normal), 0.0);
        specular = pow(spec_angle, shininess);
    }
    
    vec3 color_linear = ambient_color +
    lambertian * diffuse_color +
    specular * spec_color;
    // apply gamma correction (assume ambientColor, diffuseColor and specColor
    // have been linearized, i.e. have no gamma correction in them)
    vec3 color_gamma_corrected = pow(color_linear, vec3(1.0/screen_gamma));
    
    gl_FragColor = vec4(color_gamma_corrected, 1.0) + tex_color;
}
