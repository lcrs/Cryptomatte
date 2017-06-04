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

  // Accumulate opacity from the ranks for each picked ID
  vec4 result = vec4(0.0);
  if(separatergb) {
    if(enabler) {
      if(rank0.x == pickr.r) result.r += rank0.y;
      if(rank1.x == pickr.r) result.r += rank1.y;
      if(rank2.x == pickr.r) result.r += rank2.y;
      if(rank3.x == pickr.r) result.r += rank3.y;
      if(rank4.x == pickr.r) result.r += rank4.y;
      if(rank5.x == pickr.r) result.r += rank5.y;
    }
    if(enableg) {
      if(rank0.x == pickg.r) result.g += rank0.y;
      if(rank1.x == pickg.r) result.g += rank1.y;
      if(rank2.x == pickg.r) result.g += rank2.y;
      if(rank3.x == pickg.r) result.g += rank3.y;
      if(rank4.x == pickg.r) result.g += rank4.y;
      if(rank5.x == pickg.r) result.g += rank5.y;
    }
    if(enableb) {
      if(rank0.x == pickb.r) result.b += rank0.y;
      if(rank1.x == pickb.r) result.b += rank1.y;
      if(rank2.x == pickb.r) result.b += rank2.y;
      if(rank3.x == pickb.r) result.b += rank3.y;
      if(rank4.x == pickb.r) result.b += rank4.y;
      if(rank5.x == pickb.r) result.b += rank5.y;
    }
  } else {
    if(enableresult) {
      if(rank0.x == pickresult.r) result.rgb += vec3(rank0.y);
      if(rank1.x == pickresult.r) result.rgb += vec3(rank1.y);
      if(rank2.x == pickresult.r) result.rgb += vec3(rank2.y);
      if(rank3.x == pickresult.r) result.rgb += vec3(rank3.y);
      if(rank4.x == pickresult.r) result.rgb += vec3(rank4.y);
      if(rank5.x == pickresult.r) result.rgb += vec3(rank5.y);
    }
  }

  if(enablem) {
    if(rank0.x == pickm.r) result.a += rank0.y;
    if(rank1.x == pickm.r) result.a += rank1.y;
    if(rank2.x == pickm.r) result.a += rank2.y;
    if(rank3.x == pickm.r) result.a += rank3.y;
    if(rank4.x == pickm.r) result.a += rank4.y;
    if(rank5.x == pickm.r) result.a += rank5.y;
  }

  if(combine) {
    // Combine the picked mattes.  Since our mattes are disjoint, we just add them,
    // although if for some reason the user has picked the same ID multiple times, this will
    // result in values over 1.0
    if(separatergb) {
      result = vec4(result.r + result.g + result.b + result.a);
    } else {
      result = vec4(result.r + result.a);
    }
  }

  // If the temporary inspector widget is inside the image, output the first three mattes under
  // it into RGB
  if(0.0 < inspect.x && inspect.x < 1.0 && 0.0 < inspect.y && inspect.y < 1.0) {
    vec2 inspectrank0 = texture2D(crypto00rgb, inspect).rg;
    vec2 inspectrank1 = vec2(texture2D(crypto00rgb, inspect).b, texture2D(crypto00a, inspect).r);
    vec2 inspectrank2 = texture2D(crypto01rgb, inspect).rg;
    vec2 inspectrank3 = vec2(texture2D(crypto01rgb, inspect).b, texture2D(crypto01a, inspect).r);
    vec2 inspectrank4 = texture2D(crypto02rgb, inspect).rg;
    vec2 inspectrank5 = vec2(texture2D(crypto02rgb, inspect).b, texture2D(crypto02a, inspect).r);
    result = vec4(0.0);
    if(rank0.x == inspectrank0.r) result.ra += rank0.yy;
    if(rank1.x == inspectrank0.r) result.ra += rank1.yy;
    if(rank2.x == inspectrank0.r) result.ra += rank2.yy;
    if(rank3.x == inspectrank0.r) result.ra += rank3.yy;
    if(rank4.x == inspectrank0.r) result.ra += rank4.yy;
    if(rank5.x == inspectrank0.r) result.ra += rank5.yy;

    if(rank0.x == inspectrank1.r) result.g += rank0.y;
    if(rank1.x == inspectrank1.r) result.g += rank1.y;
    if(rank2.x == inspectrank1.r) result.g += rank2.y;
    if(rank3.x == inspectrank1.r) result.g += rank3.y;
    if(rank4.x == inspectrank1.r) result.g += rank4.y;
    if(rank5.x == inspectrank1.r) result.g += rank5.y;

    if(rank0.x == inspectrank2.r) result.b += rank0.y;
    if(rank1.x == inspectrank2.r) result.b += rank1.y;
    if(rank2.x == inspectrank2.r) result.b += rank2.y;
    if(rank3.x == inspectrank2.r) result.b += rank3.y;
    if(rank4.x == inspectrank2.r) result.b += rank4.y;
    if(rank5.x == inspectrank2.r) result.b += rank5.y;
  }

  gl_FragColor = result;
}
