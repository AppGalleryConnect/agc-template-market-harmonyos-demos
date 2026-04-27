/*
 * Copyright (c) 2024-2025 Huawei Device Co., Ltd.
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

#ifndef ARDEMO_IMAGE_LINE_RENDER_H
#define ARDEMO_IMAGE_LINE_RENDER_H

#include "app_util.h"
#include "image_render_base.h"
#include <glm.hpp>

class ImageLineRender : public ImageRenderBase {
public:
    ImageLineRender() = default;

    void Init() override;

    void OnDrawFrame(AREngine_ARSession *arSession, const AREngine_ARAugmentedImage *image, const glm::mat4 &viewMatrix,
                     const glm::mat4 &projectionMatrix) override;

private:
    int BYTES_PER_POINT = 4 * 4;

    int INITIAL_BUFFER_POINTS = 150;

    int mIndex = 0;

    std::vector<float> mCornerPointCoordinates = {};

    int mNumPoints = 0;

    int mVboSize = 150 * 4 * 4;

    int COORDINATE_DIMENSION = 3;
};

#endif // ARDEMO_IMAGE_LINE_RENDER_H
