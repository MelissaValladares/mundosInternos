shader_type spatial;

render_mode unshaded, depth_prepass_alpha;

void vertex() {
	POSITION = vec4(VERTEX, 1.0);
}

uniform sampler2D BackBufferTex : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D DepthBufferTex : hint_depth_texture, repeat_disable, filter_nearest;
uniform sampler2D NormalBufferTex: hint_normal_roughness_texture, repeat_disable, filter_nearest;
uniform float luma_threshold: hint_range(0, 1) = 0.375;
uniform float low_threshold: hint_range(0, 1) = 0.05;
uniform float high_threshold: hint_range(0, 1) = 0.2;
uniform float depth_threshold: hint_range(0, 1) = 0.1;
uniform float near = 0.05; // Set to "near" of camera, doesn't actually do anything
uniform float far = 4000.0; // Set to "far" of camera
uniform float epsilon = 0.001; // Avoid division by zero
uniform int destab_iter = 100;

// Constants for offsets
const ivec2 OffSW = ivec2(-1, 1);
const ivec2 OffSE = ivec2(1, 1);
const ivec2 OffNE = ivec2(1, -1);
const ivec2 OffNW = ivec2(-1, -1);

// Scharr operator kernels
const mat3 scharr_kernel_x = mat3(vec3(-3, 0, 3), 
								  vec3(-10, 0, 10), 
								  vec3(-3, 0, 3));

const mat3 scharr_kernel_y = mat3(vec3(-3, -10, -3), 
								  vec3(0, 0, 0), 
								  vec3(3, 10, 3));

const mat3 gaussian_kernel = mat3(vec3(0.0625, 0.125, 0.0625),
								 vec3(0.125,  0.25,  0.125),
								 vec3(0.0625, 0.125, 0.0625));

// Function to calculate luminance
float getLuma(vec3 color) {
	return dot(color, vec3(0.299, 0.587, 0.114));
}

// Function to calculate chroma
vec3 getChroma(vec3 color) {
	float maxComponent = max(max(color.r, color.g), color.b);
	return color / (maxComponent + epsilon); // Add epsilon to avoid division by zero
}

// Function to sample luminance at an offset
float sampleLumaOff(vec2 uv, ivec2 offset, vec2 texSize) {
	return getLuma(texture(BackBufferTex, uv + vec2(offset) / texSize).rgb);
}

// Sampling functions
vec3 sampleColor(vec2 p) {
	return texture(BackBufferTex, p).rgb;
}

vec3 sampleColorFromNormal(vec2 p) {
	return texture(NormalBufferTex, p).rgb;
}

// Function to linearize depth value
float linearizeDepth(float depth, vec2 uv, mat4 inv_projection_matrix) {
	vec3 ndc = vec3(uv * 2.0 - 1.0, depth);
	vec4 view = inv_projection_matrix * vec4(ndc, 1.0);
	view.xyz /= view.w;
	return -view.z;
}

// Function to calculate depth difference
float getDepthDifference(vec2 uv, vec2 texSize, mat4 inv_projection_matrix, out bool outOfBounds) {
	outOfBounds = false;
	float centerDepth = linearizeDepth(texture(DepthBufferTex, uv).x, uv, inv_projection_matrix);
	if (centerDepth > far) {
		outOfBounds = true;
	}
	float maxDepthDifference = 0.0;

	for (int x = -1; x <= 1; x++) {
		for (int y = -1; y <= 1; y++) {
			if (x == 0 && y == 0) continue; // Skip the center pixel
			vec2 offset = vec2(float(x), float(y)) / texSize;
			float neighborDepth = linearizeDepth(texture(DepthBufferTex, uv + offset).x, uv + offset, inv_projection_matrix);
			if (neighborDepth < far) {
				outOfBounds = false; 
			}
			maxDepthDifference = max(maxDepthDifference, abs(centerDepth - neighborDepth));
		}
	}

	return maxDepthDifference / (centerDepth + epsilon); // Normalize depth difference
}

vec3 gaussianBlur(vec2 uv, vec2 texSize) {
	vec3 colorSum = vec3(0.0);
	for (int x = -1; x <= 1; x++) {
		for (int y = -1; y <= 1; y++) {
			vec2 offset = vec2(float(x), float(y)) / texSize;
			colorSum += texture(BackBufferTex, uv + offset).rgb * gaussian_kernel[x + 1][y + 1];
		}
	}
	return colorSum;
}

// Function to apply Scharr filter
vec2 applyScharr(vec2 uv, vec2 texSize) {
	float gx = 0.0;
	float gy = 0.0;

	for (int x = -1; x <= 1; x++) {
		for (int y = -1; y <= 1; y++) {
			vec3 sampleColor = sampleColor(uv + vec2(float(x), float(y)) / texSize);
			float luma = getLuma(sampleColor);
			gx += luma * scharr_kernel_x[x + 1][y + 1];
			gy += luma * scharr_kernel_y[x + 1][y + 1];
		}
	}
	return vec2(gx, gy);
}

// Function to apply Scharr filter
vec2 applyScharrToNormal(vec2 uv, vec2 texSize) {
	float gx = 0.0;
	float gy = 0.0;

	for (int x = -1; x <= 1; x++) {
		for (int y = -1; y <= 1; y++) {
			vec3 sampleColor = sampleColorFromNormal(uv + vec2(float(x), float(y)) / texSize);
			float luma = getLuma(sampleColor);
			gx += luma * scharr_kernel_x[x + 1][y + 1];
			gy += luma * scharr_kernel_y[x + 1][y + 1];
		}
	}
	return vec2(gx, gy);
}

const mat3 prewitt_kernel_x = mat3(
	vec3(-1, 0, 1),
	vec3(-1, 0, 1),
	vec3(-1, 0, 1)
);
const mat3 prewitt_kernel_y = mat3(
	vec3(1, 1, 1),
	vec3(0, 0, 0),
	vec3(-1, -1, -1)
);

vec2 applyPrewitt(vec2 uv, vec2 tex_size) {
	vec2 kernel_size = vec2(3, 3);
	vec2 half_kernel = kernel_size / 2.0;
	float sum_x = 0.0;
	float sum_y = 0.0;	
	for (int i = 0; i < 3; i++) {
		for (int j = 0; j < 3; j++) {
			vec2 uv_offset = (vec2(float(i), float(j)) - half_kernel) / tex_size;
			vec4 texel = texture(BackBufferTex, uv + uv_offset);
			float intensity = (texel.r + texel.g + texel.b) / 3.0;
			sum_x += prewitt_kernel_x[i][j] * intensity;
			sum_y += prewitt_kernel_y[i][j] * intensity;
		}
	}
	return vec2(sum_x, sum_y);
}

vec2 applyPrewittToNormal(vec2 uv, vec2 tex_size) {
	vec2 kernel_size = vec2(3, 3);
	vec2 half_kernel = kernel_size / 2.0;
	float sum_x = 0.0;
	float sum_y = 0.0;	
	for (int i = 0; i < 3; i++) {
		for (int j = 0; j < 3; j++) {
			vec2 uv_offset = (vec2(float(i), float(j)) - half_kernel) / tex_size;
			vec4 texel = texture(NormalBufferTex, uv + uv_offset);
			float intensity = (texel.r + texel.g + texel.b) / 3.0;
			sum_x += prewitt_kernel_x[i][j] * intensity;
			sum_y += prewitt_kernel_y[i][j] * intensity;
		}
	}
	return vec2(sum_x, sum_y);
}

void fragment() {
	vec2 texSize = vec2(textureSize(BackBufferTex, 0));
	vec2 uv = SCREEN_UV;
	vec2 RCP2 = 2.0 / texSize;
	
	// Depth difference for depth-aware blending
	bool outOfBounds;
	float depthDifference = getDepthDifference(uv, texSize, INV_PROJECTION_MATRIX, outOfBounds);
	if (outOfBounds) {
		discard;
	}
	bool depthEdge = depthDifference > depth_threshold;
	
	// Scharr-based edge detection
	vec2 gradient = applyScharr(uv, texSize);
	float gradientMagnitude = length(gradient);
	vec2 normalGradient = applyScharrToNormal(uv, texSize);
	float normalGradientMagnitude = length(normalGradient);
	//vec2 prewittGradient = applyPrewitt(uv, texSize);
	//float prewittGradientMagnitude = length(gradient);
	//vec2 prewittNormalGradient = applyPrewittToNormal(uv, texSize);
	//float prewittNormalGradientMagnitude = length(normalGradient);

	bool isStrongEdge = gradientMagnitude >= high_threshold;// || prewittGradientMagnitude >= high_threshold;
	bool isWeakEdge = (gradientMagnitude >= low_threshold && gradientMagnitude < high_threshold);// || (prewittGradientMagnitude >= low_threshold && prewittGradientMagnitude < high_threshold);
	bool isNormalStrongEdge = normalGradientMagnitude >= high_threshold;// || prewittNormalGradientMagnitude >= high_threshold;
	bool isNormalWeakEdge = (normalGradientMagnitude >= low_threshold && normalGradientMagnitude < high_threshold);// || (prewittNormalGradientMagnitude >= low_threshold && prewittNormalGradientMagnitude < high_threshold);

	bool isConnectedToStrongEdge = false;
	if (isWeakEdge || isNormalWeakEdge) {
		for (int x = -1; x <= 1; x++) {
			for (int y = -1; y <= 1; y++) {
				if (x == 0 && y == 0) continue; // Skip the center pixel

				vec2 neighborUV = uv + vec2(float(x), float(y)) / texSize;
				vec2 neighborGradient = applyScharr(neighborUV, texSize); //neighborUV instead of uv here made it worse?
				float neighborStrength = length(neighborGradient);
				vec2 neighborNormalGradient = applyScharrToNormal(neighborUV, texSize); //neighborUV instead of uv here made it worse?
				float neighborNormalStrength = length(neighborNormalGradient);				

				if (neighborStrength > high_threshold || neighborNormalStrength > high_threshold) {
					isConnectedToStrongEdge = true;
					break;
				}
			}
			if (isConnectedToStrongEdge) break;
		}
	}

	bool cannyEdge = isStrongEdge || isNormalStrongEdge || (isWeakEdge && isConnectedToStrongEdge) || (isNormalWeakEdge && isConnectedToStrongEdge);

	// Additional luminance-based edge refinement
	vec4 lumaA;
	lumaA.x = sampleLumaOff(uv, OffSW, texSize);
	lumaA.y = sampleLumaOff(uv, OffSE, texSize);
	lumaA.z = sampleLumaOff(uv, OffNE, texSize);
	lumaA.w = sampleLumaOff(uv, OffNW, texSize);

	float gradientSWNE = lumaA.x - lumaA.z;
	float gradientSENW = lumaA.y - lumaA.w;
	vec2 dir = vec2(gradientSWNE + gradientSENW, gradientSWNE - gradientSENW);
	vec2 dirM = abs(dir);
	float dirMMin = min(dirM.x, dirM.y);
	vec2 offM = clamp(vec2(0.0625) * dirM / dirMMin, 0.0, 1.0);
	vec2 offMult = RCP2 * sign(dir);

	bool passC;
	float offMMax = max(offM.x, offM.y);
	vec4 lumaAC = lumaA;
	if (abs(offMMax - 1.0) < 0.0001) {
		bool horSpan = abs(offM.x - 1.0) < 0.0001;
		bool negSpan = horSpan ? offMult.x < 0.0 : offMult.y < 0.0;
		bool sowSpan = horSpan == negSpan;
		vec2 uvC = uv;
		if (horSpan) uvC.x += 2.0 * offMult.x;
		if (!horSpan) uvC.y += 2.0 * offMult.y;

		if (sowSpan) lumaAC.x = sampleLumaOff(uvC, OffSW, texSize);
		if (!negSpan) lumaAC.y = sampleLumaOff(uvC, OffSE, texSize);
		if (!sowSpan) lumaAC.z = sampleLumaOff(uvC, OffNE, texSize);
		if (negSpan) lumaAC.w = sampleLumaOff(uvC, OffNW, texSize);

		float gradientSWNEC = lumaAC.x - lumaAC.z;
		float gradientSENWC = lumaAC.y - lumaAC.w;
		vec2 dirC = vec2(gradientSWNEC + gradientSENWC, gradientSWNEC - gradientSENWC);

		if (!horSpan) dirC = dirC.yx;
		passC = abs(dirC.x) > 2.0 * abs(dirC.y);
		if (passC) offMult *= 2.0;
	}

	// Combine edge detections: Depth-based, Canny-based, Additional Luminance-based
	int edge = 0;
	if (depthEdge) edge += 1;
	if (cannyEdge) edge += 1;
	//if (abs(offMMax - 1.0) < 0.0001 && passC) edge += 1;
	bool isEdge = (edge > 0);
	
	// Blend colors based on combined edge detection
	vec3 finalColor;
	float finalAlpha = 1.0;
	if (isEdge) {
		// Collect neighborhood colors and chroma
		vec3 neighborhoodColors[9];
		float neighborhoodLuma[9];
		vec3 neighborhoodChroma[9];
		int index = 0;
		for (int x = -1; x <= 1; x++) {
			for (int y = -1; y <= 1; y++) {
				vec2 offset = vec2(float(x), float(y)) / texSize;
				vec3 color = texture(BackBufferTex, uv + offset).rgb;
				neighborhoodColors[index] = color;
				neighborhoodLuma[index] = getLuma(color);
				neighborhoodChroma[index] = getChroma(color);
				index++;
			}
		}

		// Calculate local variance	
		vec3 rgbM = sampleColor(uv);
		float localVariance = 0.0;
		for (int i = 0; i < 9; i++) {
			localVariance += distance(rgbM, neighborhoodColors[i]);
		}
		localVariance /= 9.0;

		// Calculate dynamic threshold based on local variance
		float dynamicThreshold = mix(luma_threshold, 1.0, localVariance); // Mix based on local variance

		if (localVariance > dynamicThreshold) {
			discard;
		}

		// Advanced blending logic
		vec2 offset = offM * offMult;
		vec3 rgbN = sampleColor(uv - offset);
		vec3 rgbP = sampleColor(uv + offset);

		// Chroma check
		float lumaMin = min(min(min(min(min(min(min(min(neighborhoodLuma[0], neighborhoodLuma[1]), neighborhoodLuma[2]), neighborhoodLuma[3]), neighborhoodLuma[4]), neighborhoodLuma[5]), neighborhoodLuma[6]), neighborhoodLuma[7]), neighborhoodLuma[8]);
		float lumaACMin = min(min(lumaAC.x, lumaAC.y), min(lumaAC.z, lumaAC.w));
		float lumaMax = max(max(max(max(max(max(max(max(neighborhoodLuma[0], neighborhoodLuma[1]), neighborhoodLuma[2]), neighborhoodLuma[3]), neighborhoodLuma[4]), neighborhoodLuma[5]), neighborhoodLuma[6]), neighborhoodLuma[7]), neighborhoodLuma[8]);
		float lumaACMax = max(max(lumaAC.x, lumaAC.y), max(lumaAC.z, lumaAC.w));
		lumaMin = min(lumaMin, lumaACMin);
		lumaMax = max(lumaMax, lumaACMax);
		vec3 chromaMin = min(min(min(min(min(min(min(min(neighborhoodChroma[0], neighborhoodChroma[1]), neighborhoodChroma[2]), neighborhoodChroma[3]), neighborhoodChroma[4]), neighborhoodChroma[5]), neighborhoodChroma[6]), neighborhoodChroma[7]), neighborhoodChroma[8]);
		vec3 chromaMax = max(max(max(max(max(max(max(max(neighborhoodChroma[0], neighborhoodChroma[1]), neighborhoodChroma[2]), neighborhoodChroma[3]), neighborhoodChroma[4]), neighborhoodChroma[5]), neighborhoodChroma[6]), neighborhoodChroma[7]), neighborhoodChroma[8]);
		bool withinRange = false;
		for (int i = 0; i < destab_iter; i++) {
			float mixmul = clamp(0.4 + ((float(i) * 0.6 / float(destab_iter)) * float(((i % 2) * 2) - 1)), 0.0, 1.0);
			vec3 rgbR = (rgbN + rgbP) * (1.0 - mixmul)/2.0 + rgbM * mixmul;			
			float lumaR = getLuma(rgbR);
			vec3 chromaR = getChroma(rgbR);
			bool lumaOutOfRange = lumaR < lumaMin || lumaR > lumaMax;		
			bool chromaOutOfRange = any(lessThan(chromaR, chromaMin)) || any(greaterThan(chromaR, chromaMax));
			if (!lumaOutOfRange && !chromaOutOfRange) {
				finalColor = rgbR;
				withinRange = true;
				break;
			}
		}
		if (!withinRange) {
			discard;
		}
	} else {
		discard; // Use the original color if not an edge
	}

	ALBEDO = finalColor;
	ALPHA = finalAlpha;
}
