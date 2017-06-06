/* Cryptomatte
     Given a set of ID/coverage pairs, extract up to four mattes
     See https://github.com/Psyop/Cryptomatte
     This shader by lewis@lewissaunders.com
     TODO: allow picking using the standard colour pots if the 65504.0
           limit is ever removed
*/

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

  vec3 picker = pickresult;
  float key_value;

  if((picker.r <= 0.0) && (picker.b == 0.0)) {
    key_value = -1.0 * picker.r;
  } else {
    key_value = picker.b;
  }

  // Compute the keyed alpha, "alpha" in the normal way, based on "key_value"
  float alpha = 0.0;
  if(rank0.x == key_value) alpha += rank0.y;
  if(rank1.x == key_value) alpha += rank1.y;
  if(rank2.x == key_value) alpha += rank2.y;
  if(rank3.x == key_value) alpha += rank3.y;
  if(rank4.x == key_value) alpha += rank4.y;
  if(rank5.x == key_value) alpha += rank5.y;
  if(key_value == 0.0) alpha = 0.0;

  vec4 out_ = vec4(0.0);
  if(alpha > 0.0) {
    out_.r = alpha;
    out_.b = rank0.x;
  } else {
    if(rank0.x > 0.0) {
      out_.r = -1.0 * rank0.x;
      out_.b = 0.0;
    } else {
      out_.r = 0.0;
      out_.b = rank0.x;
    }
  }

  out_.g = 1.0 - rank0.y;
  out_.a = alpha;

  gl_FragColor = out_;
}
