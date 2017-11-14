!!permu FRAMEBLEND
!!permu SKELETAL
!!permu FOG

varying vec4 vc;
varying vec3 light;


#ifdef VERTEX_SHADER
#include "sys/skeletal.h"
attribute vec4 v_colour;
uniform float e_time;
uniform vec3 e_light_dir;
uniform vec3 e_light_mul;
uniform vec3 e_light_ambient;

void main ()
{
	vec3 n;
	gl_Position = skeletaltransform_n(n);

	light = e_light_ambient + (dot(n,normalize(e_light_dir + vec3(0, 0, -1.5)))*e_light_mul);
	light = clamp(light, 0.2, 1.3);
	vc = v_colour;
}
#endif
#ifdef FRAGMENT_SHADER
#include "sys/fog.h"

uniform vec4 e_colourident;
void main ()
{
	vec4 col;
	col = vc;
	col.rgb *= light;
	
	gl_FragColor = fog4(col * e_colourident);
}
#endif