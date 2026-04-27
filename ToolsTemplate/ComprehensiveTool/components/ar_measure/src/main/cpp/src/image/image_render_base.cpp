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

#include "image_render_base.h"
#include "gtc/type_ptr.hpp"

void ImageRenderBase::CreateImageCorner(AREngine_ARSession *arSession, const AREngine_ARAugmentedImage *image,
                                        std::vector<float> &cornerPointCoordinates)
{
    std::vector<float> tempVector(BYTES_PER_CORNER * BYTES_PER_CORNER);

    float extent_x;
    float extent_z;
    HMS_AREngine_ARAugmentedImage_GetExtendX(arSession, image, &extent_x);
    HMS_AREngine_ARAugmentedImage_GetExtendZ(arSession, image, &extent_z);
    AREngine_ARPose *imagePose = nullptr;
    HMS_AREngine_ARPose_Create(arSession, nullptr, 0, &imagePose);
    auto getPoseResult = HMS_AREngine_ARAugmentedImage_GetCenterPose(arSession, image, imagePose);
    if (getPoseResult != ARENGINE_SUCCESS) {
        return;
    }

    glm::mat4 model(1.0f);
    CHECK(HMS_AREngine_ARPose_GetMatrix(arSession, imagePose, glm::value_ptr(model), 16));

    float imagePoseRaw[7] = {0.0f};
    CHECK(HMS_AREngine_ARPose_GetPoseRaw(arSession, imagePose, imagePoseRaw, 7));
    LOGD("HMS_AREngine_ARAugmentedImage AREngine_ARPose imagePoseRaw:x:%{public}f, y:%{public}f, z:%{public}f, "
         "rotation x:%{public}f, rotation y:%{public}f, rotation z:%{public}f, rotation w:%{public}f.",
         imagePoseRaw[4], imagePoseRaw[5], imagePoseRaw[6], imagePoseRaw[0], imagePoseRaw[1], imagePoseRaw[2],
         imagePoseRaw[3]);
    for (int i = 0; i < 4; i++) {
        std::vector<float> coefficients = {0.5f, 0.5f};
        std::vector<float> coefficient = {0.0f, 0.0f};
        switch ((CornerType)i) {
            case LOWER_RIGHT:
                // Generate the point coordinate coefficient.
                generateCoefficent(coefficient, 1, 1, coefficients);
                break;
            case UPPER_LEFT:
                generateCoefficent(coefficient, -1, -1, coefficients);
                break;
            case UPPER_RIGHT:
                generateCoefficent(coefficient, 1, -1, coefficients);
                break;
            case LOWER_LEFT:
                generateCoefficent(coefficient, -1, 1, coefficients);
                break;
            default:
                break;
        }

        int bytesPerCorner = 4;
        int cornerCoordinatePos = i * bytesPerCorner;

        glm::vec4 point(coefficient[0] * extent_x, 0.0f, coefficient[1] * extent_z, 1.0);
        point = model * point;

        tempVector[cornerCoordinatePos] = point[0];
        tempVector[++cornerCoordinatePos] = point[1];
        tempVector[++cornerCoordinatePos] = point[2];
        tempVector[++cornerCoordinatePos] = 1.0f;
    }
    HMS_AREngine_ARPose_Destroy(imagePose);
    cornerPointCoordinates = tempVector;
}

void ImageRenderBase::generateCoefficent(std::vector<float> &coefficient, int coefficentX, int coefficentZ,
                                         std::vector<float> coefficients)
{
    coefficient[0] = coefficentX * coefficients[0];
    coefficient[1] = coefficentZ * coefficients[1];
}
