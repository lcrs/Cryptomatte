uniform sampler2D uCrypto00rgb, uCrypto00a, uCrypto01rgb, uCrypto01a, uCrypto02rgb, uCrypto02a;
uniform vec3 id1, id2, id3;
uniform float tolerance;
uniform float adsk_result_w, adsk_result_h;

void main() {
  vec2 res = vec2(adsk_result_w, adsk_result_h);
  vec2 xy = gl_FragCoord.xy / res;

  vec2 a = texture2D(uCrypto00rgb, xy).rg;
  vec2 b = vec2(texture2D(uCrypto00rgb, xy).b, texture2D(uCrypto00a, xy).r);
  vec2 c = texture2D(uCrypto01rgb, xy).rg;
  vec2 d = vec2(texture2D(uCrypto01rgb, xy).b, texture2D(uCrypto01a, xy).r);
  vec2 e = texture2D(uCrypto02rgb, xy).rg;
  vec2 f = vec2(texture2D(uCrypto02rgb, xy).b, texture2D(uCrypto02a, xy).r);

  float o = 0.0;
  if(abs(id1.r - a.x) < tolerance) o += a.y;
  if(abs(id1.r - b.x) < tolerance) o += b.y;
  if(abs(id1.r - c.x) < tolerance) o += c.y;
  if(abs(id1.r - d.x) < tolerance) o += d.y;
  if(abs(id1.r - e.x) < tolerance) o += e.y;
  if(abs(id1.r - f.x) < tolerance) o += f.y;

  gl_FragColor = vec4(o);
}
