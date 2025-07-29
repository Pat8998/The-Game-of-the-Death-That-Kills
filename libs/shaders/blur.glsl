extern number blurSize;
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
    {
        vec4 sum = vec4(0.0);
        sum += Texel(texture, texture_coords + vec2(-blurSize, -blurSize)) * 0.05;
        sum += Texel(texture, texture_coords + vec2( 0.0,    -blurSize)) * 0.09;
        sum += Texel(texture, texture_coords + vec2( blurSize, -blurSize)) * 0.05;
        sum += Texel(texture, texture_coords + vec2(-blurSize,  0.0))    * 0.09;
        sum += Texel(texture, texture_coords)                          * 0.62;
        sum += Texel(texture, texture_coords + vec2( blurSize,  0.0))    * 0.09;
        sum += Texel(texture, texture_coords + vec2(-blurSize,  blurSize)) * 0.05;
        sum += Texel(texture, texture_coords + vec2( 0.0,     blurSize)) * 0.09;
        sum += Texel(texture, texture_coords + vec2( blurSize,  blurSize)) * 0.05;
        return sum * color;
    }