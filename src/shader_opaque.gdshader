shader_type spatial;

render_mode
    depth_draw_opaque,
    cull_back,
    diffuse_burley,
    specular_schlick_ggx;

//
// Material
//
uniform vec4 albedo_color : source_color = vec4(1.0);
uniform sampler2D albedo_map : source_color, hint_default_white;
uniform sampler2D normal_map : hint_normal;
uniform sampler2D metallic_map : hint_default_white;
uniform sampler2D roughness_map : hint_roughness_r;
uniform sampler2D ao_map : hint_default_white;
uniform sampler2D emission_map : source_color, hint_default_white;
uniform vec3 emission;
uniform float emission_strength;

//
// Multipliers
//
uniform float metallic : hint_range(0.0, 1.0) = 0.0;
uniform float roughness : hint_range(0.0, 1.0) = 0.5;
uniform float normal_scale : hint_range(0.0, 4.0) = 1.0;
uniform float ao_strength : hint_range(0.0, 1.0) = 1.0;

uniform vec3 selected_emission = vec3(1.0);
instance uniform float selected_emission_strength = 0.0;

//
// UV
//
uniform vec2 uv_scale = vec2(1.0);
uniform vec2 uv_offset = vec2(0.0);

void fragment() {
    vec2 uv = UV * uv_scale + uv_offset;

    // Base colour
    vec4 albedo = texture(albedo_map, uv) * albedo_color;
    ALBEDO = albedo.rgb;

    // Metallic
    METALLIC = texture(metallic_map, uv).r * metallic;

    // Roughness
    ROUGHNESS = texture(roughness_map, uv).r * roughness;

    // Normal map
    NORMAL_MAP = texture(normal_map, uv).rgb;
    NORMAL_MAP_DEPTH = normal_scale;

    // Ambient occlusion
    AO = mix(1.0, texture(ao_map, uv).r, ao_strength);

    // Emission
    EMISSION = (texture(emission_map, uv).rgb + emission) * emission_strength + selected_emission * selected_emission_strength;
}