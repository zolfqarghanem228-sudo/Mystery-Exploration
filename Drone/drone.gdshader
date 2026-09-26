shader_type canvas_item;

// المدخلات الأساسية
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// إعدادات الدرون (الألوان والتشويش)
uniform vec4 drone_color : source_color = vec4(0.7, 1.0, 0.8, 1.0); // لون مائل للأخضر
uniform float color_intensity : hint_range(0.0, 1.0) = 0.4;
uniform float scanline_density : hint_range(0.0, 1000.0) = 300.0;
uniform float noise_amount : hint_range(0.0, 0.3) = 0.06;

// إعدادات انتقال التلفاز (Transition)
uniform float transition_progress : hint_range(0.0, 1.0) = 0.0; // 0 = درون عادي، 1 = إغلاق كامل

float noise(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = SCREEN_UV;
    
    // 1. منطق انتقال التلفاز (التقلص العمودي)
    float collapse = 1.0 - transition_progress;
    // يقلص الـ UV باتجاه المركز (0.5)
    float centered_y = (uv.y - 0.5) / max(collapse, 0.0001) + 0.5;
    
    // فحص إذا كانت النقطة خارج حدود الشاشة المتقلصة
    if (centered_y < 0.0 || centered_y > 1.0) {
        COLOR = vec4(0.0, 0.0, 0.0, 1.0); // مساحة سوداء خارج الانكماش
    } else {
        // نستخدم الـ UV الجديد (المتقلص) لسحب الصورة
        vec2 drone_uv = vec2(uv.x, centered_y);
        vec4 scene_color = texture(SCREEN_TEXTURE, drone_uv);

        // 2. تطبيق تأثيرات الدرون (خطوط المسح والتشويش)
        float scanline = sin(drone_uv.y * scanline_density + TIME * 8.0) * 0.02;
        scene_color.rgb -= scanline;

        float n = (noise(drone_uv + TIME) - 0.5) * noise_amount;
        scene_color.rgb += n;

        // 3. تطبيق اللون المختار
        scene_color.rgb = mix(scene_color.rgb, scene_color.rgb * drone_color.rgb, color_intensity);

        // 4. إضافة وميض أبيض عند الإغلاق (Glow)
        float glow = pow(transition_progress, 4.0) * 3.0;
        scene_color.rgb += vec3(glow);

        COLOR = scene_color;
    }
}
