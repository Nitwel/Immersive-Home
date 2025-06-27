shader_type spatial;
render_mode skip_vertex_transform,blend_mix,depth_draw_opaque,cull_disabled,diffuse_burley,specular_schlick_ggx,unshaded;

uniform vec4 albedo;
uniform float point_size;
uniform sampler2D position_noise;

uniform float streamrad = 3.0;
uniform float sparkrad = 0.2;
uniform float sparktrailrad = 0.08;
uniform float noisedisplacementfac = 0.04;

void vertex() {
	float growtimefac = COLOR.r;
	float timefac = COLOR.r;
	float springoutfac = 1.0 - pow(1.0 - timefac, 3.0);
	float noisetimefac = (timefac*timefac*0.5 - timefac + 1.0)*0.09;
	float UVycollapsed = (UV.y > 0.5 ? 0.6 : UV.y*1.0);
	if (UV.y < 0.3)  UVycollapsed *= 1.2;

	float noisedisplacement = noisedisplacementfac*springoutfac*25.0*pow(UVycollapsed, 3.0);
	float fadetimefac = COLOR.g;

	vec2 streamvec = normalize((MODELVIEW_MATRIX * vec4(0.0, 1.0, 0.0, 0.0)).xy);
	float noiserowdisp = fract(VERTEX.z*100.0);
	float noiserow = min(UV.y, 0.6) + 0.2*noiserowdisp;
	float prevnoiserow = max(noiserow - 0.2, 0.0);
	vec4 normnoise = texture(position_noise, vec2(noisetimefac, noiserow));
	VERTEX.xyz += vec3((normnoise.x-0.5)*noisedisplacement, (normnoise.z-0.99)*noisedisplacement, (normnoise.y-0.5)*noisedisplacement);
	VERTEX.y += UVycollapsed*streamrad*springoutfac;

    VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;

	vec2 perpstreamvec = vec2(streamvec.y, -streamvec.x);
	float aspect = length(PROJECTION_MATRIX[1].xyz)/length(PROJECTION_MATRIX[0].xyz);
	if (UV.y > 0.75) {
		VERTEX.xy += ((UV.x - 0.5)*perpstreamvec + (UV.y - 0.9)*5.0*streamvec)*sparkrad;
	} else {
		VERTEX.xy += (UV.x - 0.5)*perpstreamvec*sparktrailrad;
	}
}

void fragment() {
	if ((UV.y >= 0.6) && (UV.y <= 0.8))
		discard;
	bool bspark = (UV.y >= 0.8);
	float dd = length(vec2(UV.x*2.0 - 1.0,
					  (bspark ? (UV.y - 0.9)*10.0 : pow(abs(UV.y - 0.3)/0.33, 4.0))));

    ALBEDO = min(vec3(1.0), vec3(0.9, 0.6, 0.7)*(0.3/(dd + 0.01)) +
				 (bspark ? vec3(0.3, 0.1, 1.0) : vec3(0.0, 0.6, 0.0)));
	ALPHA = clamp(1.0 - dd*dd*4.0, 0.0, 1.0);

	float fadeperiod = UV.y*UV.y*0.4 + 0.01;
	fadeperiod = UV.y*0.5;
	if (COLOR.r > 1.0 - fadeperiod)
		ALPHA *= (1.0 - COLOR.r)/fadeperiod;
}
