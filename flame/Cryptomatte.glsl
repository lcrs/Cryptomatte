/* Cryptomatte
     Given a set of ID/coverage pairs, extract up to four mattes
     See https://github.com/Psyop/Cryptomatte
     This shader by lewis@lewissaunders.com
     TODO: allow picking using the standard colour pots if the 65504.0
           limit is ever removed
*/

#extension GL_EXT_gpu_shader4 : enable

// Image resolution
uniform float adsk_result_w, adsk_result_h;

// The usual 3 RGBA Cryptomatte layers are loaded by Flame as 3 RGB/matte pairs
uniform sampler2D crypto00rgb, crypto00a, crypto01rgb, crypto01a, crypto02rgb, crypto02a;

// Our colour picker widgets and whether they're enabled
uniform vec3 pickresult, pickr, pickg, pickb, pickm;
uniform bool enableresult, enabler, enableg, enableb, enablem;

// Whether we should output a single matte on RGB, or three separate mattes
uniform bool separatergb;

// Whether we should output the sum of all picked mattes
uniform bool combine;

// Dummy button with tooltip to remind about using the floating colour sampler
uniform bool reminder;

// Widget which is temporarily draggable over the image to inspect available mattes
uniform vec2 inspect;
  
float frexp(float x, out float e) {
  e = ceil(log2(x));
  return(x * exp2(-e));
}

bool isnan(float f) {
  // Try a few things.  Some drivers optimise some of them away :/
  if(f != f) {
    return true;
  }
  if(f < 0.0 || 0.0 < f || f == 0.0) {
    return false;
  } else {
    return true;
  }
}

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void main() {
  // Convert fragment coords in pixels to texel coords in [0..1]
  vec2 res = vec2(adsk_result_w, adsk_result_h);
  vec2 xy = gl_FragCoord.xy / res;

  // In these vectors the first element is the ID, the second the coverage
  vec2 rank0 = texture2D(crypto00rgb, xy).rg;
  vec2 rank1 = vec2(texture2D(crypto00rgb, xy).b, texture2D(crypto00a, xy).r);
  vec2 rank2 = texture2D(crypto01rgb, xy).rg;
  vec2 rank3 = vec2(texture2D(crypto01rgb, xy).b, texture2D(crypto01a, xy).r);
  vec2 rank4 = texture2D(crypto02rgb, xy).rg;
  vec2 rank5 = vec2(texture2D(crypto02rgb, xy).b, texture2D(crypto02a, xy).r);

  vec4 result = vec4(0.0);

  // Massage the rank0 ID into a more uniform range
  float seed, e;
  seed = frexp(rank0.x, e);
  if(isnan(seed)) seed = frexp(-rank0.x, e);
  if(isnan(seed)) seed = 0.0;

  // Seed red/green noise with it
  result.r = rand(vec2(seed, seed));
  result.g = rand(vec2(seed, 5.0 * seed));

  // Reduce contrast and add some outlines from the rank0 coverage
  if(result.rg != vec2(0.0)) result.rg = mix(result.rg, vec2(0.3), 0.5);
  result = mix(result, result * rank0.y, 0.5);

  // Secrete the rank0 ID in the blue channel, but always negative
  if(rank0.x < 0.0) {
    result.rg *= 256.0;
    result.rg = floor(result.rg);
    result.rg /= 256.0;
    result.b = rank0.x;
  } else {
    result.rg *= 256.0;
    result.rg = floor(result.rg);
    result.rg += vec2(0.5);
    result.rg /= 256.0;
    result.b = -rank0.x;
  }

  float pick = pickresult.b;
  if(fract(pickresult.r * 256.0) > 0.0) {
    pick = -pick;
  }
  if(rank0.x == pick) result.a += rank0.y;
  if(rank1.x == pick) result.a += rank1.y;
  if(rank2.x == pick) result.a += rank2.y;
  if(rank3.x == pick) result.a += rank3.y;
  if(rank4.x == pick) result.a += rank4.y;
  if(rank5.x == pick) result.a += rank5.y;

  result.rg += result.a;

  gl_FragColor = result;
}
