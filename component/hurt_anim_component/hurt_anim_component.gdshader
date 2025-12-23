shader_type canvas_item;

uniform float lerp_percent :hint_range(0.0, 1.0);

void fragment() {
	// 获取像素颜色
  vec4 texture_color = texture(TEXTURE,UV);
  
  vec4 final_color = mix(texture_color,vec4(1.0,1.0,1.0,texture_color.a),lerp_percent);
  
  // 输出到屏幕
  COLOR = final_color;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
