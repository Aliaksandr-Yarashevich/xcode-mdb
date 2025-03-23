#include <metal_stdlib>
using namespace metal;

constant float M_PI = 3.14159265358979323846264338327950288;

kernel void mandelbrot(
                       texture2d<float, access::write> output [[texture(0)]],
                       uint2 gid [[thread_position_in_grid]],
                       constant float2 *viewportSize [[buffer(1)]],
                       constant float2 *center [[buffer(2)]],
                       constant float *zoom [[buffer(3)]],
                       constant int *depth [[buffer(4)]]) {
    if (gid.x >= viewportSize->x || gid.y >= viewportSize->y) return;

    float2 c = (*center) + (float2(gid) - *viewportSize / 2.0) / (*zoom);
    float2 z = 0;
    int iterations = 0, maxIterations = *depth;

    while (length(z) < 2.0 && iterations < maxIterations) {
        z = float2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
        iterations++;
    }

    float t = float(iterations) / maxIterations;
    float colorR = pow(1 - abs(1 - t * 2), 1)  * (0.5 + 0.5 * sin(t * M_PI * 6 - M_PI / 2));
    float colorG = pow(t, 2)                   * (0.5 + 0.5 * sin(t * M_PI * 6 - M_PI / 2));// sin(t * M_PI / 2);
    float colorB = (0.5 + 0.5 * cos(t * M_PI)) * (0.5 + 0.5 * sin(t * M_PI * 6 - M_PI / 2));// 1 - cos(t * M_PI / 2);

                           
//    uchar4 color = uchar4(t * 255, (1.0 - t) * 255, t * 128, 255);
//    float4 color = float4(pow(t, 0.9), pow(t, 0.2), t, 1.0);
    float4 color = float4(colorR, colorG, colorB, 1.0);
//    output[gid.y * int(viewportSize->x) + gid.x] = color;
    
    output.write(color, gid);
}
