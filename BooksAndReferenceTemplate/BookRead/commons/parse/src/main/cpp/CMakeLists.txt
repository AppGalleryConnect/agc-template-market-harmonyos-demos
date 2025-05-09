# the minimum version of CMake.
cmake_minimum_required(VERSION 3.5.0)
project(read)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})
set(CMAKE_VERBOSE_MAKEFILE ON)

if (DEFINED PACKAGE_FIND_FILE)
    include(${PACKAGE_FIND_FILE})
endif ()

include_directories(${NATIVERENDER_ROOT_PATH}
        ${NATIVERENDER_ROOT_PATH}/include
        ${CMAKE_CURRENT_SOURCE_DIR}/third/pugixml
        ${CMAKE_CURRENT_SOURCE_DIR}/entity
        ${CMAKE_CURRENT_SOURCE_DIR}/utils
        ${CMAKE_CURRENT_SOURCE_DIR}/constants)

add_library(parse SHARED
        parse/epub_parser.cpp
        manager/epub_manager.cpp
        entity/manifest.cpp
        entity/metadata.cpp
        entity/chapter.cpp
        entity/page_rect.cpp
        entity/render_entity.cpp
        entity/catalog.cpp
        third_party/pugixml/src/pugixml.cpp
        napi_init.cpp
        render/page_render.cpp
)
target_link_libraries(parse PUBLIC libace_napi.z.so hilog_ndk.z libnative_drawing.so)
