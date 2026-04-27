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

/**
 * @file i_gl_render_engine.h
 * @brief OpenGL ES rendering engine interface for video and image processing
 * @details This header defines the interface for a rendering engine that supports
 *          both static and dynamic image rendering with OpenGL ES, including
 *          video frame processing and image overlay capabilities.
 */

#ifndef HMOS_OPEN_GL_IMAGE_RENDER_A2_I_GL_RENDER_ENGINE_H
#define HMOS_OPEN_GL_IMAGE_RENDER_A2_I_GL_RENDER_ENGINE_H

#include <cstdint>
#include <multimedia/player_framework/native_avformat.h>
#include <native_buffer/native_buffer.h>
#include <native_image/native_image.h>
#include <native_window/external_window.h>
#include <string>
#include <vector>

/**
 * @brief Base structure containing common properties for static and dynamic images
 * @details This abstract base class defines the common attributes that both
 *          static and dynamic images share in the rendering system.
 */
struct ImageInfoBase {
    double_t scale = 0;  /**< Scale factor for image rendering */
    double_t pos_x = 0;  /**< X-coordinate calculated based on viewport size */
    double_t pos_y = 0;  /**< Y-coordinate calculated based on viewport size */
    float rotate = 0;    /**< Rotation angle in degrees */
    uint32_t frames = 0; /**< Number of frames in the image sequence */

    /**
     * @brief Virtual destructor to ensure proper cleanup of derived classes
     */
    virtual ~ImageInfoBase() = default;
};

/**
 * @brief Structure for static image information (single frame)
 * @details Inherits from ImageInfoBase and adds single-frame specific properties
 *          for static image rendering.
 */
struct StaticImageInfo : public ImageInfoBase {
    OH_NativeBuffer *nativeBuffer = nullptr; /**< Single frame image buffer */
};

/**
 * @brief Structure for dynamic image information (multi-frame)
 * @details Inherits from ImageInfoBase and adds multi-frame specific properties
 *          for animated image rendering such as GIFs.
 */
struct DynamicImageInfo : public ImageInfoBase {
    bool isGif = true;                                /**< Flag indicating if this is a GIF animation */
    std::vector<OH_NativeBuffer *> nativeBufferArray; /**< Array of multi-frame image buffers */
    std::vector<uint32_t> frameDelayArray;            /**< Array of frame delay times in milliseconds */
};

/**
 * @brief Viewport parameters for rendering calculations
 * @details Contains the dimensions of the viewport used for coordinate calculations
 *          and rendering area definition.
 */
struct ViewParams {
    uint32_t width;  /**< Viewport width in pixels */
    uint32_t height; /**< Viewport height in pixels */
};

/**
 * @brief Interface for OpenGL ES rendering engine
 * @details This abstract class defines the interface for a rendering engine that
 *          supports video frame processing and image overlay rendering using OpenGL ES.
 *          It provides methods for adding static and dynamic images, managing rendering
 *          surfaces, and controlling the rendering lifecycle.
 */
class IGLRenderEngine {
public:
    /**
     * @brief Creates a new instance of the rendering engine
     * @return Shared pointer to the created rendering engine instance
     */
    static std::shared_ptr<IGLRenderEngine> Create();

    /**
     * @brief Virtual destructor for proper cleanup
     */
    virtual ~IGLRenderEngine() = default;

    /**
     * @brief Adds a static image to the rendering pipeline
     * @param staticImageInfo Shared pointer to static image information
     * @return Image ID for later reference, or negative value on error
     */
    virtual int32_t AddStaticImage(std::shared_ptr<StaticImageInfo> staticImageInfo) = 0;

    /**
     * @brief Adds a dynamic image (e.g., GIF) to the rendering pipeline
     * @param dynamicImageInfo Shared pointer to dynamic image information
     * @return Image ID for later reference, or negative value on error
     */
    virtual int32_t AddDynamicImage(std::shared_ptr<DynamicImageInfo> dynamicImageInfo) = 0;

    /**
     * @brief Gets the input surface for video frame input
     * @return Pointer to the input native window surface
     */
    virtual OHNativeWindow *GetInSurface() = 0;

    /**
     * @brief Sets the output surface for rendering
     * @param outSurface Pointer to the output native window surface
     * @return 0 on success, negative value on error
     */
    virtual int32_t SetOutSurface(OHNativeWindow *outSurface) = 0;

    /**
     * @brief Sets the input video format information
     * @param avFormat Pointer to the video format structure
     * @return 0 on success, negative value on error
     */
    virtual int32_t SetInVideoFormat(OH_AVFormat *avFormat) = 0;

    /**
     * @brief Starts the rendering engine
     * @return 0 on success, negative value on error
     */
    virtual int32_t Start() = 0;

    /**
     * @brief Configures viewport parameters for coordinate calculations
     * @details The width and height parameters do not affect the output video size,
     *          they are only used for calculating image coordinates relative to the viewport.
     * @param viewParams Viewport parameters containing width and height
     */
    virtual void SetViewParams(ViewParams viewParams) = 0;

    /**
     * @brief Removes an image from the rendering pipeline by ID
     * @param imageId The ID of the image to remove
     * @return true if successful, false otherwise
     */
    virtual bool RemoveImage(int32_t imageId) = 0;

    /**
     * @brief Clears all images from the rendering pipeline
     */
    virtual void ClearImages() = 0;
};

#endif // HMOS_OPEN_GL_IMAGE_RENDER_A2_I_GL_RENDER_ENGINE_H
