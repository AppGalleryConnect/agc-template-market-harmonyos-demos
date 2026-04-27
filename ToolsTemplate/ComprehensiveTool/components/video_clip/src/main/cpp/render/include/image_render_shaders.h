/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef OPENGL_IMAGE_RENDER_SHADERS_H
#define OPENGL_IMAGE_RENDER_SHADERS_H
namespace HarmonyVideoEditorRender {
namespace Detail {
// 顶点着色器（GLSL ES 300）
const char *imageVertexShader = R"delimiter(#version 300 es
layout (location = 0) in vec3 position;  
layout (location = 1) in vec2 texCoord;

out vec2 vTexCoord;  

uniform mat4 matTransform;
uniform mat4 orthoMatrix;  // 正交矩阵，通过参数传入

void main()
{
    gl_Position =  orthoMatrix * matTransform * vec4(position, 1.0);
    vTexCoord = texCoord;  
}
)delimiter";

// 片段着色器（GLSL ES 300）
const char *imageFragmentShader = R"delimiter(#version 300 es
precision mediump float;
precision mediump sampler2DArray;
in vec2 vTexCoord;
out vec4 FragColor;

uniform sampler2DArray texArray;
uniform int uFrameIndex;
uniform bool isInputP3;

// Display P3 到 XYZ 转换矩阵（D65白点）
const mat3 P3_TO_XYZ = mat3(
    0.4866, 0.2657, 0.1982,
    0.2289, 0.6917, 0.0793, 
    0.0000, 0.0451, 1.0439
);

// XYZ 到 sRGB 转换矩阵（D65白点）
const mat3 XYZ_TO_SRGB = mat3(
    3.2406, -1.5372, -0.4986,
    -0.9689, 1.8758, 0.0415,
    0.0557, -0.2040, 1.0570
);

vec3 gammaToLinear(vec3 color) {
    return mix(
        color / 12.92,  // 暗部线性转换（适用于color <= 0.04045的通道）
        pow((color + 0.055) / 1.055, vec3(2.4)),  // 亮部非线性转换
        step(0.04045, color)  // 根据阈值生成选择掩码（0.0或1.0）
    );
}

vec3 linearToGamma(vec3 color) {
    return mix(
        color * 12.92,  // 暗部线性转换（适用于color <= 0.0031308的通道）
        1.055 * pow(color, vec3(1.0 / 2.4)) - 0.055,  // 亮部非线性转换
        step(0.0031308, color)  // 根据阈值生成选择掩码
    );
}
void main() {
    // 采样输入颜色
    vec4 inputColor = texture(texArray, vec3(vTexCoord, float(uFrameIndex)));
    
   if (isInputP3) {
        // Gamma解码
        vec3 linearP3 = gammaToLinear(inputColor.rgb);
        // P3到XYZ转换
        vec3 xyz = linearP3 * P3_TO_XYZ;
        // XYZ到sRGB转换
        vec3 linearSRGB = xyz * XYZ_TO_SRGB;
        // Gamma编码
        vec3 outputColor = linearToGamma(linearSRGB);
        //输出
        FragColor = vec4(clamp(outputColor, 0.0, 1.0), inputColor.a);
    } else {
        // sRGB 不做处理，直接输出
        FragColor = inputColor;
    }
}
)delimiter";

const char *videoVertexShader = R"delimiter(#version 300 es

layout(location = 0) in vec3 position;  
layout(location = 1) in vec2 texCoord;

out vec2 vTexCoord;

uniform mat4 matTransform;

void main()
{
    gl_Position = matTransform * vec4(position, 1.0);
    vTexCoord = texCoord;
}
)delimiter";

const char *videoFragmentShader = R"delimiter(#version 300 es
#extension GL_EXT_YUV_target : require
#extension GL_OES_EGL_image_external_essl3 : require
precision highp float;

in vec2 vTexCoord;
uniform highp __samplerExternal2DY2YEXT sTexture;

uniform bool isInputBt601;       // 输入是否为BT.601色彩空间
uniform bool isInputFullRange;  // 输入是否为Full Range

out vec3 FragColor;

// BT.601到BT.709的YUV转换矩阵
const mat3 BT601_TO_BT709_YUV = mat3(
    1.0,  0.0,  0.0,
    0.0,  0.989,  0.011,
    0.0,  0.011,  0.989
);

void main() {
    // 1. 采样YUV数据
    vec3 yuv = texture(sTexture, vTexCoord).rgb;
    
    // 2. 在YUV空间处理range转换
    if (!isInputFullRange) {
        // Limited Range YUV → Full Range YUV
        yuv.x = (yuv.x - 0.062745098) / 0.8588;  // Y分量: (Y-16)/219
        yuv.y = (yuv.y - 0.5) / 0.8784 + 0.5;    // U分量: (U-128)/224 + 0.5
        yuv.z = (yuv.z - 0.5) / 0.8784 + 0.5;    // V分量: (V-128)/224 + 0.5
    }
    
    // 3. 色域转换（如果需要从BT.601转换到BT.709）
    if (isInputBt601) {
        // 在YUV空间进行BT.601到BT.709转换
        yuv = BT601_TO_BT709_YUV * yuv;
    }

    // 4. YUV→RGB转换
    vec3 rgb;
    if (isInputBt601) {
        rgb.r = yuv.x + 1.402 * (yuv.z - 0.5);
        rgb.g = yuv.x - 0.344 * (yuv.y - 0.5) - 0.714 * (yuv.z - 0.5);
        rgb.b = yuv.x + 1.772 * (yuv.y - 0.5);
    }else{
        rgb.r = yuv.x + 1.5748 * (yuv.z - 0.5);
        rgb.g = yuv.x - 0.1873 * (yuv.y - 0.5) - 0.4681 * (yuv.z - 0.5);
        rgb.b = yuv.x + 1.8556 * (yuv.y - 0.5);
    }
    // 5. 最终限制RGB范围并输出
    rgb = clamp(rgb, 0.0, 1.0);
    FragColor = rgb;
}
)delimiter";
} // namespace Detail
} // namespace HarmonyVideoEditorRender
#endif // OPENGL_IMAGE_RENDER_SHADERS_H
