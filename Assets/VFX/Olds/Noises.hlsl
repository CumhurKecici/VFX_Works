/*
float perlin_2d(float x, float y)
{
  int X;
  int Y;

  float fx = floorfrac(x, &X);
  float fy = floorfrac(y, &Y);

  float u = fade(fx);
  float v = fade(fy);

  float r = bi_mix(grad2(hash_uint2(X, Y), fx, fy),
                   grad2(hash_uint2(X + 1, Y), fx - 1.0f, fy),
                   grad2(hash_uint2(X, Y + 1), fx, fy - 1.0f),
                   grad2(hash_uint2(X + 1, Y + 1), fx - 1.0f, fy - 1.0f),
                   u,
                   v);

  return r;
}
*/
float2 unity_gradientNoise_dir(float2 p)
{
    p = p % 289;
    float x = (34 * p.x + 1) * p.x % 289 + p.y;
    x = (34 * x + 1) * x % 289;
    x = frac(x / 41) * 2 - 1;
    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

float perlin_2d(float2 p)
{
    float2 ip = floor(p);
    float2 fp = frac(p);
    float d00 = dot(unity_gradientNoise_dir(ip), fp);
    float d01 = dot(unity_gradientNoise_dir(ip + float2(0, 1)), fp - float2(0, 1));
    float d10 = dot(unity_gradientNoise_dir(ip + float2(1, 0)), fp - float2(1, 0));
    float d11 = dot(unity_gradientNoise_dir(ip + float2(1, 1)), fp - float2(1, 1));
    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
    return lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x);
}

float2 snoise_2d(float2 p)
{
    float2 precision_correction = 0.5f * float2(float(abs(p.x) >= 1000000.0f), float(abs(p.y) >= 1000000.0f));
    /* Repeat Perlin noise texture every 100000.0f on each axis to prevent floating point
    * representation issues. This causes discontinuities every 100000.0f, however at such scales
    * this usually shouldn't be noticeable. */
    p = fmod(p, 100000.0f) + precision_correction;
    

    return perlin_2d(p) * 0.6616f;
}

float noise_fbm(float2 p, float detail, float roughness, float lacunarity, bool normalize)
{
    float fscale = 1.0f;
    float amp = 1.0f;
    float maxamp = 0.0f;
    float sum = 0.0f;
  
    for (int i = 0; i <= int(detail); i++) {
      float t = snoise_2d(fscale * p);
      sum += t * amp;
      maxamp += amp;
      amp *= roughness;
      fscale *= lacunarity;
    }
    float rmd = detail - floor(detail);
    if (rmd != 0.0f) {
      float t = snoise_2d(fscale * p);
      float sum2 = sum + t * amp;
      return normalize ? lerp(0.5f * sum / maxamp + 0.5f, 0.5f * sum2 / (maxamp + amp) + 0.5f, rmd) :
                         lerp(sum, sum2, rmd);
    }
    else {
      return normalize ? 0.5f * sum / maxamp + 0.5f : sum;
    }
}



void FBMNoise_float(float2 p, float detail, float roughness, float lacunarity, bool normalize, out float Out)
{
    Out = noise_fbm(p, detail, roughness, lacunarity, normalize); 

    
}