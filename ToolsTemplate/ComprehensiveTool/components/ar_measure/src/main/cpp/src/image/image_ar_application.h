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

#ifndef ARDEMO_IMAGE_AR_APPLICATION_H
#define ARDEMO_IMAGE_AR_APPLICATION_H

#include "app_napi.h"
#include "app_util.h"
#include "ar/ar_engine_core.h"
#include "image_render_manager.h"
#include "task_queue.h"
#include "world/world_file_manager.h"
#include <cstdint>
#include <string>

namespace ARImage {
class ARImageApp : public AppNapi {
public:
    explicit ARImageApp(std::string &id);
    ~ARImageApp() override;

    void OnStart(const ConfigParams &params) override;
    void OnUpdate() override;
    void OnPause() override;
    void OnResume() override;
    void OnStop() override;
    // XComponent Callback
    void OnSurfaceCreated(OH_NativeXComponent *component, void *window) override;
    void OnSurfaceChanged(OH_NativeXComponent *component, void *window) override;
    void OnSurfaceDestroyed(OH_NativeXComponent *component, void *window) override;
    void DispatchTouchEvent(OH_NativeXComponent *component, void *window) override;

private:
    AREngine_ARSession *mArSession = nullptr;
    AREngine_ARFrame *mArFrame = nullptr;
    AREngine_ARPoseType mDisplayRotation = ARENGINE_POSE_TYPE_IDENTITY;
    uint64_t mWidth = 1080;
    uint64_t mHeight = 1920;
    ConfigParams mConfigParam{};
    bool mIsSurfaceChange = false;
    uint32_t mNotifyShowPage = 0;
    std::mutex mMutex;
    TaskQueue mTaskQueue; // update 更新线程
    double mX = 0.0;
    double mY = 0.0;
    std::atomic<bool> isPaused = false;

    ARWorld::WorldFileManager mWorldFileManager = ARWorld::WorldFileManager();

    ImageRenderManager mImageRenderManager;

    std::mutex mImageMutex;

    AREngine_ARAugmentedImageDatabase *mDataBase = nullptr;

    std::vector<std::string> paths = {"0001.jpg", "0002.jpg", "0003.jpg",         "0004.jpg", "0005.jpg", "0006.jpg",
                                      "0007.jpg", "0008.jpg", "0009.jpg",         "0010.jpg", "0011.jpg", "0012.jpg",
                                      "0013.jpg", "0014.jpg", "0015.jpg",         "0016.jpg", "0017.jpg", "0019.jpg",
                                      "0020.jpg", "0021.jpg", "image_default.png"};
    std::string path = "/data/storage/el2/base/haps/entry/files/testbin.bin";
};

} // namespace ARImage

#endif // ARDEMO_IMAGE_AR_APPLICATION_H
