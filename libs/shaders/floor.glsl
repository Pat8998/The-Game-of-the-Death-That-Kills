extern number fov;
extern vec2 screenSize;
extern vec3 cameraPos;
extern number gridSize;
extern number lineWidth;
extern number cameraYaw;     // horizontal angle (radians)
extern number cameraPitch;   // vertical angle (radians)

mat3 rotationMatrix(float yaw, float pitch) {
    // Yaw: rotation around Y axis
    float cosY = cos(yaw);
    float sinY = sin(yaw);
    // Pitch: rotation around X axis
    float cosP = cos(pitch);
    float sinP = sin(pitch);

    // Apply pitch first, then yaw
    return mat3(
        cosY, 0.0, -sinY,
        sinY * sinP, cosP, cosY * sinP,
        sinY * cosP, -sinP, cosY * cosP
    );
}

vec4 effect(vec4 color, Image tex, vec2 uv, vec2 screen_coords) {
    float px = (screen_coords.x / screenSize.x) * 2.0 - 1.0;
    float py = 1.0 - (screen_coords.y / screenSize.y) * 2.0;


    float aspect = screenSize.x / screenSize.y;
    vec3 ray = normalize(vec3(px * aspect * tan(fov / 2.0), py * tan(fov / 2.0), -1.0));

    // Rotate the ray using the camera angles
    mat3 rot = rotationMatrix(cameraYaw, cameraPitch);
    ray = rot * ray;

    // Intersect ray with ground plane at y=0
    float t = -cameraPos.y / ray.y;
    if (t < 0.0) discard;

    vec3 hit = cameraPos + ray * t;

    float fade = max(min(sqrt(pow(hit.x - cameraPos.x, 2.0) + pow(hit.z - cameraPos.z, 2.0)) * 0.01, 2.0), 0.5);

    vec2 floorUV = hit.xz / gridSize;
    vec4 texColor = Texel(tex, floorUV);
    vec4 tint = vec4(0.1, 0.5, 5, 1.0); // color
    texColor *= tint;
    //texColor.rgb *= fade;
    texColor *= vec4(1, 1, 1, fade);
    return texColor;

    float caca = lineWidth;
}
