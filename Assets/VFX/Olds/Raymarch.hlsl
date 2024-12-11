//Based on code from DMEville https://www.youtube.com/watch?v=0G8CVQZhMXw

//Uses 3D texture and lighting 
void raymarch_float( float3 rayOrigin, float3 rayDirection, float numSteps, float stepSize,
    float densityScale, UnityTexture3D volumeTex, UnitySamplerState volumeSampler,
    float3 offset, float numLightSteps, float lightStepSize, float3 lightDir,
    float lightAbsorb, float darknessThreshold, float transmittance, out float3 result )
{
    float density = 0;
    float transmission = 0;
    float lightAccumulation = 0;
    float finalLight = 0;


    for(int i =0; i< numSteps; i++){
        rayOrigin += (rayDirection*stepSize);

        //The blue dot position
        float3 samplePos = rayOrigin+offset;
        float sampledDensity = SAMPLE_TEXTURE3D(volumeTex, volumeSampler, samplePos).r;
        density += sampledDensity*densityScale;

        //light loop
        float3 lightRayOrigin = samplePos;

        for(int j = 0; j < numLightSteps; j++){
        //The red dot position
        lightRayOrigin += -lightDir*lightStepSize;
        float lightDensity = SAMPLE_TEXTURE3D(volumeTex, volumeSampler, lightRayOrigin).r;
        //The accumulated density from samplePos to the light - the higher this value the less light reaches samplePos
        lightAccumulation += lightDensity;
        }

        //The amount of light received along the ray from param rayOrigin in the direction rayDirection
        float lightTransmission = exp(-lightAccumulation);
        //shadow tends to the darkness threshold as lightAccumulation rises
        float shadow = darknessThreshold + lightTransmission * (1.0 -darknessThreshold);
        //The final light value is accumulated based on the current density, transmittance value and the calculated shadow value 
        finalLight += density*transmittance*shadow;
        //Initially a param its value is updated at each step by lightAbsorb, this sets the light lost by scattering
        transmittance *= exp(-density*lightAbsorb);
    
        }

    transmission = exp(-density);

    result = float3(finalLight, transmission, transmittance);
}

void raymarchv1_float( float3 rayOrigin, float3 rayDirection, float numSteps, float stepSize,
    float densityScale, float4 Sphere, float sampleValue, out float result ){
        float density = 0;

        for(int i =0; i< numSteps; i++){
        rayOrigin += (rayDirection*stepSize);
        
        //Calculate density
        float sphereDist = distance(rayOrigin, Sphere.xyz);

        if(sphereDist < Sphere.w){
        //density += 0.1;
        density += sampleValue*densityScale;
        }
        
    }

    result = density * densityScale;
}

void raymarchv2_float( float3 rayOrigin, float3 rayDirection, float numSteps, float stepSize,
      float densityScale, UnityTexture3D volumeTex, UnitySamplerState volumeSampler,
      float3 offset, out float result )
    {
    float density = 0;
    float transmission = 0;

    for(int i =0; i< numSteps; i++){
    rayOrigin += (rayDirection*stepSize);
    
    //Calculate density
    float sampledDensity = SAMPLE_TEXTURE3D(volumeTex, volumeSampler, rayOrigin + offset).r;
    density += sampledDensity;
    
    }

    result = density * densityScale;
}

void raymarchv3_float( float3 rayOrigin, float3 rayDirection, float numSteps, float stepSize,
      float densityScale, UnityTexture3D volumeTex, UnitySamplerState volumeSampler,
      float3 offset, float numLightSteps, float lightStepSize, float3 lightPosition,
      out float result )
    {
    float density = 0;
    float lightAccumulation = 0;
    //offset -= SHADERGRAPH_OBJECT_POSITION;

    for(int i =0; i< numSteps; i++){
    rayOrigin += (rayDirection*stepSize);
    float3 samplePos = rayOrigin+offset;		
    //Calculate density
    float sampledDensity = SAMPLE_TEXTURE3D(volumeTex, volumeSampler, samplePos).r;
    density += sampledDensity;

    float3 lightRayOrigin = samplePos;
    float3 lightDir = samplePos - lightPosition;

    for(int j = 0; j < numLightSteps; j++){
    lightRayOrigin += lightDir*lightStepSize;
    float lightDensity = SAMPLE_TEXTURE3D(volumeTex, volumeSampler, lightRayOrigin).r;
    lightAccumulation += lightDensity;
    }	
    }

    result = density * densityScale;
}



inline float unity_noise_randomValue (float2 uv)
{
    return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453);
}

inline float unity_noise_interpolate (float a, float b, float t)
{
    return (1.0-t)*a + (t*b);
}

inline float unity_valueNoise (float2 uv)
{
    float2 i = floor(uv);
    float2 f = frac(uv);
    f = f * f * (3.0 - 2.0 * f);

    uv = abs(frac(uv) - 0.5);
    float2 c0 = i + float2(0.0, 0.0);
    float2 c1 = i + float2(1.0, 0.0);
    float2 c2 = i + float2(0.0, 1.0);
    float2 c3 = i + float2(1.0, 1.0);
    float r0 = unity_noise_randomValue(c0);
    float r1 = unity_noise_randomValue(c1);
    float r2 = unity_noise_randomValue(c2);
    float r3 = unity_noise_randomValue(c3);

    float bottomOfGrid = unity_noise_interpolate(r0, r1, f.x);
    float topOfGrid = unity_noise_interpolate(r2, r3, f.x);
    float t = unity_noise_interpolate(bottomOfGrid, topOfGrid, f.y);
    return t;
}

float SimpleNoise(float2 UV, float Scale)
{
    float t = 0.0;

    float freq = pow(2.0, float(0));
    float amp = pow(0.5, float(3-0));
    t += unity_valueNoise(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

    freq = pow(2.0, float(1));
    amp = pow(0.5, float(3-1));
    t += unity_valueNoise(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

    freq = pow(2.0, float(2));
    amp = pow(0.5, float(3-2));
    t += unity_valueNoise(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

    return t;
}

float Remap(float In)
{
    float2 InMinMax = float2(-1, 1);
    float2 OutMinMax = float2(0, 1);
    return OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}


void CloudVolume_float(float3 rayOrigin, float3 rayDirection, float3 center, float scale, UnityTexture3D volumeTex, UnitySamplerState volumeSampler, out float Out)
{
    float stepSize = 0.02;
    float densityScale = 0.02;

    float density = 0;

    for(int i = 0; i < 64; i++)
    {
        rayOrigin += (rayDirection * stepSize);

        float sampledDensity = max(SimpleNoise(rayOrigin.xy, scale), SimpleNoise(rayOrigin.zy, scale));
        sampledDensity = SAMPLE_TEXTURE3D(volumeTex, volumeSampler, rayOrigin + center).r;
        density += sampledDensity;
    }

    Out = density * densityScale;
}