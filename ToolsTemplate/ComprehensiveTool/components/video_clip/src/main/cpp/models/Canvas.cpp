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

#include "Canvas.h"
#include "Editor.h"
#include "VideoAsset.h"
#include "Timeline.h"

void Canvas::SetCanvasSize(uint32_t height, uint32_t width)
{
    LOGI("Canvas::SetCanvasSize height %{public}d width %{public}d", height, width);
    
    this->height = height; // 这里变量同名了，用this指代成员变量不然赋值不上。
    this->width = width;
    std::shared_ptr<Timeline> timeline = Editor::GetInstance().GetTimeline();
    if (timeline == nullptr) {
        LOGE("Editor::SetCanvasSize timeline is nullptr");
        return;
    }
    
    std::shared_ptr<VideoAsset> mainVideo = timeline->GetMainVideo();
    if (mainVideo == nullptr) {
        LOGE("Editor::SetCanvasSize mainVideo is nullptr");
        return;
    }
    
    if (mainVideo->GetHeight()==0 || mainVideo->GetWidth()==0) {
        LOGE("Editor::SetCanvasSize mainVideo height or width not prepared");
        return;
    }
    
    float ratioVideo;
    float ratioCanvas = (float)width / (float)height;
    uint32_t rotation = mainVideo->GetRotation();
    
    if (rotation == 90 || rotation == 270) {
        // 如果视频有旋转度则交换宽高
        ratioVideo = (float)mainVideo->GetHeight() / (float)mainVideo->GetWidth();
        LOGI("Editor::SetCanvasSize swap video width and height");
    } else {
        ratioVideo = (float)mainVideo->GetWidth() / (float)mainVideo->GetHeight();
    }
   
    LOGI("Editor::SetCanvasSize ratioVideo is %{public}f, ratioCanvas is %{public}f", ratioVideo, ratioCanvas);
    if (ratioVideo <= ratioCanvas) {
        drawableHeight = height;
        drawableWidth = height * ratioVideo;
    } else {
        drawableWidth = width;
        drawableHeight = width / ratioVideo;
    }
    
    LOGI("Editor::SetCanvasSize drawable height %{public}d width %{public}d", 
            drawableHeight, 
            drawableWidth
    );
}

std::vector<std::pair<uint32_t, uint32_t>> Canvas::GetDrawableArea()
{
    LOGI("Canvas::GetDrawableArea.");
    std::vector<std::pair<uint32_t, uint32_t>> res{};
    if (drawableWidth == 0 | drawableHeight == 0) {
        LOGE("Canvas::GetDrawableArea Didnt set canvas,");
        return {};
    }
    
    if (drawableWidth == width) {
        LOGI("Canvas::GetDrawableArea width is same.");
        uint32_t topBorder = (height - drawableHeight)/2;
        uint32_t bottomBorder = (height + drawableHeight)/2;
        LOGI("Canvas::GetDrawableArea width is %{public}d, top border is %{public}d, left border is %{public}d",
             width,
             topBorder,
             bottomBorder
             );
        res.push_back(std::pair<uint32_t, uint32_t>(0, topBorder));
        res.push_back(std::pair<uint32_t, uint32_t>(width, topBorder));
        res.push_back(std::pair<uint32_t, uint32_t>(width, bottomBorder));
        res.push_back(std::pair<uint32_t, uint32_t>(0, bottomBorder));
        realOrigin = std::pair<float, float>{0, topBorder};
        LOGI("Canvas::GetDrawableArea real origin is %{public}d, %{public}d", realOrigin.first, realOrigin.second);
        return res;
    }
    
    if (drawableHeight == height) {
        LOGI("Canvas::GetDrawableArea height is same.");
        uint32_t leftBorder = (width - drawableWidth)/2;
        uint32_t rightBorder = (width + drawableWidth)/2;
        LOGI("Canvas::GetDrawableArea height is %{public}d, left border is %{public}d, right border is %{public}d",
             height,
             leftBorder,
             rightBorder
             );
        res.push_back(std::pair<uint32_t, uint32_t>(leftBorder, 0));
        res.push_back(std::pair<uint32_t, uint32_t>(rightBorder, 0));
        res.push_back(std::pair<uint32_t, uint32_t>(rightBorder, height));
        res.push_back(std::pair<uint32_t, uint32_t>(rightBorder, height));
        realOrigin = std::pair<float, float>{leftBorder, 0};
        LOGI("Canvas::GetDrawableArea real origin is %{public}d, %{public}d", realOrigin.first, realOrigin.second);
        return res;
    }
    
    LOGE("Canvas::GetDrawableArea Invalid drawable area.");
    return {};
}