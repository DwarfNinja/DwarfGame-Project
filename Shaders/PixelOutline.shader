shader_type canvas_item;
render_mode blend_mix; //used to be unshaded

uniform bool Enabled = true;
uniform float width : hint_range(0.0, 16) = 1.0;
uniform vec4 outline_color : hint_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform int pixel_size : hint_range(1, 10) = 4;
uniform float alphaThreshold = 0.5; 

void fragment() {
    if(Enabled) {
        vec2 unit = (1.0/float(pixel_size) ) / vec2(textureSize(TEXTURE, 0));
        vec4 pixel_color = texture(TEXTURE, UV);
        vec4 out_color = vec4(0.0);
        if (pixel_color.a <= alphaThreshold) {
            for (float x = -ceil(width); x <= ceil(width); x++) {
                for (float y = -ceil(width); y <= ceil(width); y++) {
                    if (texture(TEXTURE, UV + vec2(x*unit.x, y*unit.y)).a <= alphaThreshold || (x==0.0 && y==0.0)) {
                        continue;
                        }
                    out_color = outline_color;
                    }
                }
            }
    pixel_color = mix(pixel_color, out_color, out_color.a);
    COLOR = pixel_color;
    }
}