uniform sampler2D uCrypto00rgb, uCrypto00a, uCrypto01rgb, uCrypto01a, uCrypto02rgb, uCrypto02a;
uniform float adsk_result_w, adsk_result_h;
uniform float id;

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
  if(a.x == id) o += a.y;
  if(b.x == id) o += b.y;
  if(c.x == id) o += c.y;
  if(d.x == id) o += d.y;
  if(e.x == id) o += e.y;
  if(f.x == id) o += f.y;

  gl_FragColor = vec4(o);
}
