#
#  Copyright (c) 2024-2025 Huawei Device Co., Ltd.
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

# the minimum version of CMake.
cmake_minimum_required(VERSION 3.5.0)

# project
project(ARSample)

set(CMAKE_CXX_STANDARD 17)
set(NATIVE_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

find_library(arengine-lib libarengine_ndk.z.so)

# include directory
include_directories(
    ${NATIVE_ROOT_PATH}/src
    ${NATIVE_ROOT_PATH}/src/utils
    ${NATIVE_ROOT_PATH}/src/graphic
    ${NATIVE_ROOT_PATH}/thirdparty/glm
    ${NATIVE_ROOT_PATH}/thirdparty/stb
)

# Build shared library.
add_library(entry SHARED
    # common
    ${NATIVE_ROOT_PATH}/src/module.cpp
    ${NATIVE_ROOT_PATH}/src/napi_manager.cpp
    ${NATIVE_ROOT_PATH}/src/global.cpp
    ${NATIVE_ROOT_PATH}/src/utils/app_util.cpp
    ${NATIVE_ROOT_PATH}/src/utils/app_file.cpp
    ${NATIVE_ROOT_PATH}/src/utils/renderer_ref.cpp
    ${NATIVE_ROOT_PATH}/src/graphic/GLUtils.cpp
    ${NATIVE_ROOT_PATH}/src/graphic/RenderAttribute.cpp
    ${NATIVE_ROOT_PATH}/src/graphic/RenderContext.cpp
    ${NATIVE_ROOT_PATH}/src/graphic/RenderSurface.cpp

    # world
    ${NATIVE_ROOT_PATH}/src/world/world_ar_application.cpp
    ${NATIVE_ROOT_PATH}/src/world/world_background_renderer.cpp
    ${NATIVE_ROOT_PATH}/src/world/world_object_renderer.cpp
    ${NATIVE_ROOT_PATH}/src/world/world_plane_renderer.cpp
    ${NATIVE_ROOT_PATH}/src/world/world_render_manager.cpp
    ${NATIVE_ROOT_PATH}/src/world/world_file_manager.cpp

    # depth
    ${NATIVE_ROOT_PATH}/src/depth/depth_ar_application.cpp
    ${NATIVE_ROOT_PATH}/src/depth/depth_background_renderer.cpp
    ${NATIVE_ROOT_PATH}/src/depth/depth_render_manager.cpp
    ${NATIVE_ROOT_PATH}/src/depth/depth_background_no_renderer.cpp

     # mesh
    ${NATIVE_ROOT_PATH}/src/mesh/mesh_ar_application.cpp
    ${NATIVE_ROOT_PATH}/src/mesh/mesh_background_renderer.cpp
    ${NATIVE_ROOT_PATH}/src/mesh/mesh_render_manager.cpp
    ${NATIVE_ROOT_PATH}/src/mesh/scenemesh_display_renderer.cpp
    ${NATIVE_ROOT_PATH}/src/mesh/mesh_object_renderer.cpp

    # image
    ${NATIVE_ROOT_PATH}/src/image/image_ar_application.cpp
    ${NATIVE_ROOT_PATH}/src/image/image_background_renderer.cpp
    ${NATIVE_ROOT_PATH}/src/image/image_render_manager.cpp
    ${NATIVE_ROOT_PATH}/src/image/image_render_base.cpp
    ${NATIVE_ROOT_PATH}/src/image/image_line_render.cpp

    # semanticdense
    ${NATIVE_ROOT_PATH}/src/semanticdense/semanticdense_ar_application.cpp
    ${NATIVE_ROOT_PATH}/src/semanticdense/semanticdense_background_renderer.cpp
    ${NATIVE_ROOT_PATH}/src/semanticdense/semanticdense_point_cloud_renderer.cpp
    ${NATIVE_ROOT_PATH}/src/semanticdense/semanticdense_render_manager.cpp
    ${NATIVE_ROOT_PATH}/src/semanticdense/semanticdense_cube_renderer.cpp
)

# Link the OpenHarmony native library (using OpenGL).
target_link_libraries(entry PUBLIC
    EGL
    GLESv3
    hilog_ndk.z
    ace_ndk.z
    ace_napi.z
    z
    uv
    ace_napi.z
    rawfile.z
    libohfileio.so
    image_source
    pixelmap
    pixelmap_ndk.z
    ${arengine-lib}
    libnative_display_manager.so
)
