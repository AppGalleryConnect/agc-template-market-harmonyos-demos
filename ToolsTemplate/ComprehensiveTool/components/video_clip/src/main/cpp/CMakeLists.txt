# the minimum version of CMake.
cmake_minimum_required(VERSION 3.5.0)
project(veditor)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})
set(CMAKE_CXX_STANDARD 17)

if(DEFINED PACKAGE_FIND_FILE)
    include(${PACKAGE_FIND_FILE})
endif()

set(BASE_LIBRARY libace_napi.z.so libpixelmap.so libnative_buffer.so libimage_source.so libnative_window.so
                 libhilog_ndk.z.so libace_ndk.z.so libuv.so libvideo_processing.so
                 libimage_processing.so libnative_media_codecbase.so libnative_media_core.so
                 libnative_media_vdec.so libnative_media_venc.so libnative_media_acodec.so
                 libnative_media_avdemuxer.so libnative_media_avsource.so libnative_media_avmuxer.so libohaudio.so
                 libnative_buffer.so libnative_vsync.so libnative_image.so libEGL.so libGLESv3.so libnative_color_space_manager.so
                 libohfileuri.so
)

include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/interface
                    ${NATIVERENDER_ROOT_PATH}/include
                    ${NATIVERENDER_ROOT_PATH}/models
                    ${NATIVERENDER_ROOT_PATH}/render/include
                    ${NATIVERENDER_ROOT_PATH}/models/assets/include
                    ${NATIVERENDER_ROOT_PATH}/avcodec/include
                    ${NATIVERENDER_ROOT_PATH}/avcodec/common
)

set(MODEL_SRC ${NATIVERENDER_ROOT_PATH}/interface/napi_init.cpp
              ${NATIVERENDER_ROOT_PATH}/interface/js_utils.cpp
              ${NATIVERENDER_ROOT_PATH}/interface/index.cpp
              ${NATIVERENDER_ROOT_PATH}/interface/asyncwork.cpp
              ${NATIVERENDER_ROOT_PATH}/models/Editor.cpp
              ${NATIVERENDER_ROOT_PATH}/models/Timeline.cpp
              ${NATIVERENDER_ROOT_PATH}/models/Canvas.cpp
              ${NATIVERENDER_ROOT_PATH}/models/utils.cpp
              ${NATIVERENDER_ROOT_PATH}/models/assets/Asset.cpp
              ${NATIVERENDER_ROOT_PATH}/models/assets/AudioAsset.cpp
              ${NATIVERENDER_ROOT_PATH}/models/assets/ImageAsset.cpp
              ${NATIVERENDER_ROOT_PATH}/models/assets/VideoAsset.cpp
)

add_library(veditor SHARED ${MODEL_SRC})

add_library(render SHARED   ${NATIVERENDER_ROOT_PATH}/render/egl_render_context.cpp
                            ${NATIVERENDER_ROOT_PATH}/render/shader_program.cpp
                            ${NATIVERENDER_ROOT_PATH}/render/render_engine.cpp
                            ${NATIVERENDER_ROOT_PATH}/render/image_manager.cpp
)

add_library(avcodec SHARED ${NATIVERENDER_ROOT_PATH}/avcodec/common/avcodec_callback.cpp
                           ${NATIVERENDER_ROOT_PATH}/avcodec/audio_decoder.cpp
                           ${NATIVERENDER_ROOT_PATH}/avcodec/audio_encoder.cpp
                           ${NATIVERENDER_ROOT_PATH}/avcodec/av_decoder_engine.cpp
                           ${NATIVERENDER_ROOT_PATH}/avcodec/av_decoder_engine_impl.cpp
                           ${NATIVERENDER_ROOT_PATH}/avcodec/av_encoder_engine.cpp
                           ${NATIVERENDER_ROOT_PATH}/avcodec/demuxer.cpp
                           ${NATIVERENDER_ROOT_PATH}/avcodec/muxer.cpp
                           ${NATIVERENDER_ROOT_PATH}/avcodec/pcm_buffer_queue.cpp
                           ${NATIVERENDER_ROOT_PATH}/avcodec/video_decoder.cpp
                           ${NATIVERENDER_ROOT_PATH}/avcodec/video_encoder.cpp
                           ${NATIVERENDER_ROOT_PATH}/avcodec/video_process.cpp
                           ${NATIVERENDER_ROOT_PATH}/avcodec/audio_proresampler_process.c
                           ${NATIVERENDER_ROOT_PATH}/avcodec/audio_proresampler.cpp
)

target_link_libraries(avcodec PUBLIC ${BASE_LIBRARY})

target_link_libraries(render PUBLIC ${BASE_LIBRARY})

target_link_libraries(veditor PUBLIC avcodec render ${BASE_LIBRARY})