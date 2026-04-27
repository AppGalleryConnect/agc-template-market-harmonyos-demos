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

#ifndef ARDEMO_IMAGE_RENDER_MANAGER_H
#define ARDEMO_IMAGE_RENDER_MANAGER_H

#include "ar/ar_engine_core.h"
#include "graphic/RenderContext.h"
#include "graphic/RenderSurface.h"
#include "image_background_renderer.h"
#include "image_line_render.h"
#include "image_render_base.h"
#include <list>
#include <mutex>

namespace ARImage {
class ImageRenderManager {
public:
    ImageRenderManager() = default;
    ~ImageRenderManager() = default;

    void Initialize(void *window);

    void Release();

    void OnDrawFrame(AREngine_ARSession *arSession, AREngine_ARFrame *arFrame);

    void DrawBlack();

    ImageBackgroundRenderer GetBackgroundRender() { return mBackgroundRenderer; }

protected:
    void ImageRender(AREngine_ARSession *arSession, glm::mat4 &viewMat, const glm::mat4 &projectionMat);

private:
    RenderContext mRenderContext;
    RenderSurface mRenderSurface;

    ImageBackgroundRenderer mBackgroundRenderer;
    bool isInited = false;

    std::mutex mPoseMutex;
    float cameraPoseRaw[8] = {0.0f};
    std::list<ImageRenderBase *> mImageRenderList;
};

} // namespace ARImage

#endif // ARDEMO_IMAGE_RENDER_MANAGER_H
