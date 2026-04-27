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

#include "Editor.h"
#include "AudioAsset.h"
#include "ImageAsset.h"
#include "Timeline.h"
#include "VideoAsset.h"
#include "callbacks.h"
#include "codec_common.h"
#include "i_av_decoder_engine.h"
#include "i_av_encoder_engine.h"
#include "i_gl_render_engine.h"
#include "utils.h"
#include <cstdint>
#include <fcntl.h>
#include <memory>
#include <native_window/external_window.h>
#include <multimedia/native_audio_channel_layout.h>
#include <thread>
#include <unistd.h>

static std::atomic<size_t> decoderFrameCount{0}; // 记录导出时decoder解码的帧数数量
static std::atomic<bool> isDecoderStopped{false}; // 标记导出时decoder是否停止
static std::atomic<size_t> encoderFrameCount{0}; // 记录encoder编码的帧数数量，用于判断是否停止导出


static std::shared_ptr<LambdaAVDecoderCallback> previewDecoderCallback =
    std::make_shared<LambdaAVDecoderCallback>([](uint64_t pts) { Editor::GetInstance().OnPlay(pts); },
                                              [](CodecStatus status) {
                                                  // 预览时到结尾循环播
                                                  if (status == CodecStatus::END_OF_STREAM) {
                                                        std::thread t([]() { Editor::GetInstance().PlayFromStart(); });
                                                        t.detach();
                                                  }
                                              });

static std::shared_ptr<LambdaAVDecoderCallback> exportDecoderCallback = std::make_shared<LambdaAVDecoderCallback>(
    [](uint64_t pts) {
        auto timeline = Editor::GetInstance().GetTimeline();
        if (timeline == nullptr) {
            LOGE("exportDecoderCallback:: no timeline");
            return;
        }
    
        uint64_t endPos = timeline->GetVideoEndPos();
    
        // 未解码到期望位置前记录解码的帧数
        if(pts < endPos && !isDecoderStopped) {
            decoderFrameCount += 1;
        } 
        // 利用decoder的pts和duration判断是否解码到期望位置。
        if(pts >= endPos) {
            LOGI("exportDecoderCallback:: export decoder stopped before target pts.");
            isDecoderStopped = true;
        }
        LOGD("exportDecoderCallback:: frame no. %{public}d, pts is %{public}d, end pos is %{public}d duration is %{public}d", 
                decoderFrameCount.load(), 
                pts, 
                endPos,
                timeline->GetDuration()
        );
    },
                                                                                                                  
    [](CodecStatus status) { 
        if (status == CodecStatus::END_OF_STREAM) {
            // 如果视频轨结束了，直接标记解码结束
            LOGI("exportDecoderCallback:: export decoder stopped at video end.");
            isDecoderStopped = true;
            
            // 导出时若不裁剪，由于pts不准确只有解码器遇到eos才会设置标志位，而遇到eos不会送帧，
            // 若编码器在这之前处理完最后一帧会导致卡住，所以在此特殊处理。（导出HDR视频可复现）
            
            if (decoderFrameCount.load() <= encoderFrameCount.load()) {
                std::thread t([]() {
                    auto encoderEngine = Editor::GetInstance().GetEncoderEngine();
                    encoderEngine->SendEOS();
                    if (Editor::GetInstance().m_exportSendEnd) {
                        napi_call_threadsafe_function(Editor::GetInstance().m_exportSendEnd, nullptr, napi_tsfn_nonblocking);
                    }
                });
                t.detach();
            }
        }
    });

static std::shared_ptr<LambdaAVEncoderCallback> exportEncoderCallback = std::make_shared<LambdaAVEncoderCallback>(
    [](uint64_t pts) {
        // 记录编码的帧数用于判断导出结束
        encoderFrameCount += 1;
        Editor::GetInstance().OnExport(pts);
        LOGD("exportEncoderCallback:: frame no. %{public}d, %{public}d", encoderFrameCount.load(), pts);
    },
    [](CodecStatus status) {

    });

Editor &Editor::GetInstance()
{
    static Editor editor;
    return editor;
}

Editor::Editor() {}

std::shared_ptr<Timeline> Editor::GetTimeline() { return m_timeline; }

std::shared_ptr<Canvas> Editor::GetCanvas() { return m_canvas; }

std::shared_ptr<IAVDecoderEngine> Editor::GetPreviewEngine() { return m_previewEngine; }

std::shared_ptr<IAVEncoderEngine> Editor::GetEncoderEngine() { return m_encoderEngine; }

std::shared_ptr<IGLRenderEngine> Editor::GetRenderEngine() { return m_renderEngine; }

void Editor::Init()
{   
    LOGI("Editor::Init.");
    // 创建并初始化Timeline
    m_timeline = std::make_shared<Timeline>();
    m_canvas = std::make_shared<Canvas>();
    
    std::shared_ptr<IGLRenderEngine> renderEngine = IGLRenderEngine::Create();
    if (renderEngine == nullptr) {
        LOGE("render engine is nullptr");
        return;
    }
    m_renderEngine = renderEngine;
}

void Editor::Destroy()
{   
    LOGI("Editor::Destroy.");
    // Asset的资源会在析构函数里自动释放，不用在editor里手动
    if (m_isPreviewEngineStopped == false) {
        VEditorStatus status = Editor::Stop();
        if (status == VEditorStatus::STATUS_ERROR) {
            LOGD("Editor::Destroy. preview engine stop failed");
        }
    }
    if (m_previewEngine != nullptr) {
        m_previewEngine->Stop();
        m_previewEngine = nullptr;
    }
    if (m_exportEngine != nullptr) {
        m_exportEngine ->Stop();
        m_exportEngine = nullptr;
    }
    if (m_renderEngine != nullptr) {
        // m_renderEngine->Stop(); render引擎的stop调用会空指针crash
        m_renderEngine = nullptr;
    }
    if (m_inVideoFormat != nullptr) {
        OH_AVFormat_Destroy(m_inVideoFormat);
        m_inVideoFormat = nullptr;
    }
    CloseFds();
    napi_release_threadsafe_function(m_exportSendEnd, napi_tsfn_abort);
    napi_release_threadsafe_function(m_exportSendProgress, napi_tsfn_abort);
    Reset();
}

void Editor::Reset()
{
    m_timeline = nullptr;
    m_previewEngine = nullptr;
    m_exportEngine = nullptr; 
    m_encoderEngine = nullptr;
    m_renderEngine = nullptr;
    m_canvas = nullptr;
    m_previewWindow = nullptr; // 裸指针，nativeWindow生命周期由前端管理。
    
    m_bufferQueue = nullptr;
    m_openedFds = {}; // 打开的文件描述符，Editor析构前要销毁;
    m_isPlayReady = false;
    m_isExportReady = false;
    
    m_inVideoFormat = nullptr;
    m_firstFrame = false;
    m_sendEos = false;
    m_isPreviewEngineStopped = false;
    m_exportSendEnd = nullptr;
    m_exportSendProgress = nullptr;
    m_progress = 0.0f;
    decoderFrameCount = 0; 
    isDecoderStopped = false; 
    encoderFrameCount = 0;
}

void Editor::TrackFd(int32_t fd) {
    LOGI("Editor::TrackFd.");
    m_openedFds.push_back(fd);
}

void Editor::CloseFds()
{   
    LOGI("Editor::CloseFds.");
    for (int32_t fd : m_openedFds) {
        close(fd);
    }
    m_openedFds = {};
}

VEditorStatus Editor::Play()
{
    LOGI("Editor::Play.");

    int32_t status = m_previewEngine->Start();
    if (status == AVError::AV_ERROR) 
        return VEditorStatus::STATUS_OK;  // todo: log
   
    return VEditorStatus::STATUS_OK;
}

VEditorStatus Editor::PlayFromStart()
{
    LOGI("Editor::PlayFromStart.");
    
    // seek and play
    int32_t status;
    int64_t startPos = m_timeline->GetVideoStartPos();
    LOGD("Editor::PlayFromStart seek to %{public}d", startPos);
    status = m_previewEngine->Seek(startPos/1000, OH_AVSeekMode::SEEK_MODE_CLOSEST_SYNC);
    
    if (status == AVError::AV_ERROR)
        return VEditorStatus::STATUS_ERROR;
    
    // LOGD("Editor::PlayFromStart play");
    status = Play();
    if (status == AVError::AV_ERROR)
        return VEditorStatus::STATUS_ERROR;
    
    return VEditorStatus::STATUS_OK;
}

VEditorStatus Editor::Stop()
{   
    // stop只析构预览引擎
    LOGI("Editor::Stop.");
    if (m_isPreviewEngineStopped == false) {
        int32_t status;
        if (m_previewEngine != nullptr) {
            status = m_previewEngine->Stop();
        }
        
        if (status == AVError::AV_ERROR)
            return VEditorStatus::STATUS_ERROR;
        m_isPreviewEngineStopped = true;
    }
    return VEditorStatus::STATUS_OK;
}

VEditorStatus Editor::Pause()
{
    LOGI("Editor::Pause.");
    int32_t status = m_previewEngine->Pause();
    
    if (status == AVError::AV_ERROR)
        return VEditorStatus::STATUS_ERROR;
    
    return VEditorStatus::STATUS_OK;
}

VEditorStatus Editor::Export()
{
    LOGI("Editor::Export.");
    if (m_isExportReady == false) {
        LOGE("Editor::Export export is not ready");
        return VEditorStatus::STATUS_ERROR;
    }
    
    // 检查所有引擎指针
    if (m_renderEngine == nullptr || m_encoderEngine == nullptr || m_exportEngine == nullptr) {
        LOGE("Editor::Export engine(s) not initialized: render=%d, encoder=%d, export=%d",
             m_renderEngine != nullptr, m_encoderEngine != nullptr, m_exportEngine != nullptr);
        return VEditorStatus::STATUS_ERROR;
    }
    
    int32_t status; 
    LOGI("Editor::Export render engine start.");
    
    status = m_renderEngine->Start();
    if(status == AVError::AV_ERROR) {
        LOGE("Editor::Export render engine start failed.");
        return VEditorStatus::STATUS_ERROR;
    }
    std::this_thread::sleep_for(std::chrono::milliseconds(100));
    LOGI("Editor::Export encoder engine start.");
    status = m_encoderEngine->Start();
    if(status == AVError::AV_ERROR) {
        LOGE("Editor::Export encoder engine start failed.");
        return VEditorStatus::STATUS_ERROR;
    }
    
    std::shared_ptr<VideoAsset> mainVideo = m_timeline->GetMainVideo();
    if (mainVideo == nullptr) {
        LOGE("Editor::Export main video is nullptr.");
        return VEditorStatus::STATUS_ERROR;
    }
    
    // seek 到截取的地方, 单位毫秒
    status = m_exportEngine->Seek(mainVideo->GetStartPos()/1000, OH_AVSeekMode::SEEK_MODE_CLOSEST_SYNC);
    if(status == AVError::AV_ERROR) {
        LOGE("Editor::Export decoder engine seek failed.");
        return VEditorStatus::STATUS_ERROR;
    }
    
    LOGD("Editor::Export seek to real startPos %{public}d", mainVideo->GetStartPos());
    LOGI("Editor::Export export decoder engine start.");
    status = m_exportEngine->Start(); // decoder
    if(status == AVError::AV_ERROR) {
        LOGE("Editor::Export decoder engine start failed.");
        return VEditorStatus::STATUS_ERROR;
    }
    
    return VEditorStatus::STATUS_OK;
}

VEditorStatus Editor::PrepareExportEngine(std::string savePath)
{
    LOGI("Editor::PrepareExportEngine");
    if (m_isExportReady == true) {
        LOGD("Editor::PrepareExportEngine already prepared");
        return VEditorStatus::STATUS_OK;
    }
    std::shared_ptr<VideoAsset> mainVideo = m_timeline->GetMainVideo();
    if (mainVideo == nullptr) {
        LOGE("Editor::PrepareExportEngine no main video.");
        return VEditorStatus::STATUS_ERROR;
    }
    

    int32_t fdVideo = mainVideo->GetSourceFd();
    if (fdVideo == -1) {
        LOGE("Editor::PrepareExportEngine open video failed.");
        return VEditorStatus::STATUS_ERROR;
    }
    TrackFd(fdVideo);
    LOGD("Editor::PrepareExportEngine video fd is %{public}d", fdVideo);
    
    // Create decoder for export
    std::shared_ptr<IAVDecoderEngine> decoderEngine = IAVDecoderEngine::Create(fdVideo, exportDecoderCallback);
    if (decoderEngine == nullptr) {
        LOGE("Editor::PrepareExportEngine Create export decoder engine failed.");
        return VEditorStatus::STATUS_ERROR;
    }
    int32_t status;
    // mainVideo->SetIsMuted(true); // test mute
    // renderEngine的input window设置给decoderEngine
    status = decoderEngine->SetVideoOutputWindow(m_renderEngine->GetInSurface());
    if(status == AVError::AV_ERROR) {
        LOGE("Editor::PrepareExportEngine Set decoder output window failed.");
        return VEditorStatus::STATUS_ERROR;
    }
    
    decoderEngine->SetHighPerformance(true);
    status = decoderEngine->Init();
    
    if(status == AVError::AV_ERROR) {
        LOGE("Editor::PrepareExportEngine Init decoder failed.");
        return VEditorStatus::STATUS_ERROR;
    }
    
    status = decoderEngine->AudioUnselect(mainVideo->IsMuted());
    if(status == AVError::AV_ERROR) {
        LOGE("Editor::PrepareExportEngine select video audio failed.");
        return VEditorStatus::STATUS_ERROR;
    }
    // test audio 
    // m_timeline->SetBgAudio("data/storage/el2/base/haps/app/files/2.mp3");
    
    // Add bgAudio;
    std::shared_ptr<AudioAsset> bgAudio = m_timeline->GetBgAudio();
    if (bgAudio != nullptr) {
        int32_t fdAudio = bgAudio->GetSourceFd();
        if (fdAudio == -1) {
            LOGE("Editor::PrepareExportEngine open Audio failed.");
            return VEditorStatus::STATUS_ERROR;
        }
        
        TrackFd(fdAudio);
        LOGI("Editor::PrepareExportEngine audio fd is %{public}d", fdAudio);
        
        decoderEngine->AddAudio(fdAudio);
    }
    
    
    // add images
    LOGD("Editor::PrepareExportEngine Add image, real origin is %{public}f, %{public}f", 
        m_canvas->realOrigin.first,
        m_canvas->realOrigin.second
    );

    for (auto image: m_timeline->GetImages()) {
        LOGD("Editor::PrepareExportEngine Add image %{public}s", image->GetId().c_str());
        
        //LOGI("Editor::PrepareExportEngine real point first %{public}f, %{public}f", m_canvas->realOrigin.first, m_canvas->realOrigin.second);
        image->PrepareImage(m_canvas->realOrigin.first, m_canvas->realOrigin.second);
        std::shared_ptr<ImageInfoBase> imageInfo = image->GetImageInfo();
        if(imageInfo == nullptr) {
            LOGE("Editor::PrepareExportEngine imageInfo is nullptr");
            return VEditorStatus::STATUS_ERROR;
        }
        if (image->IsGif()) {
            m_renderEngine->AddDynamicImage(std::static_pointer_cast<DynamicImageInfo>(imageInfo));
        } else {
            m_renderEngine->AddStaticImage(std::static_pointer_cast<StaticImageInfo>(imageInfo));   
        }
    }
    
    // 设置渲染需要的videoFormat
    status = m_renderEngine->SetInVideoFormat(m_inVideoFormat);
    if(status == AVError::AV_ERROR) {
        LOGE("Editor::PrepareExportEngine select render engine inVideo format failed.");
        return VEditorStatus::STATUS_ERROR;
    }
    
    // 预览视口的大小设置给渲染引擎
    ViewParams viewParams;
    viewParams.width = m_canvas->drawableWidth;
    viewParams.height = m_canvas->drawableHeight;
    LOGI("Editor::PrepareExportEngine set viewParams width is %{public}d, height is %{public}d", 
        viewParams.width, 
        viewParams.height
    );
    
    int inputWidth, inputHeight;
    // 处理之后的视频旋转角为0，这里调换一下宽高使底层封装的就是旋转的视频
    if (mainVideo->GetRotation() == 90 || mainVideo->GetRotation() == 270) {
        inputWidth = mainVideo->GetHeight();
        inputHeight = mainVideo->GetWidth();
    } else {
        inputWidth = mainVideo->GetWidth();
        inputHeight = mainVideo->GetHeight();
    }
    
    LOGI("Editor::PrepareExportEngine input video width is %{public}d, height is %{public}d",
        inputWidth,
        inputHeight
    );
    
    int outputWidth, outputHeight;
    
    if (std::min(inputHeight, inputWidth) < 720) {
        outputWidth = inputWidth;
        outputHeight = inputHeight;
        LOGI("Editor::PrepareExportEngine use original resolution.");
    } else {
        outputWidth = inputWidth;
        outputHeight = inputHeight;
        LOGI("Editor::PrepareExportEngine use original resolution when 720p+.");
    }
    
    LOGI("Editor::PrepareExportEngine set encode window width is %{public}d, height is %{public}d",
        outputWidth,
        outputHeight
    );    
    
    // 设置导出需要的视频编码的avFormat，有些暂时没有改，因为改了要同步pts
    OH_AVFormat *exportFormat = OH_AVFormat_Create();
    OH_AVFormat_Copy(exportFormat, m_inVideoFormat);

    OH_AVFormat_SetIntValue(exportFormat, OH_MD_KEY_COLOR_PRIMARIES, OH_ColorPrimary::COLOR_PRIMARY_BT709);
    OH_AVFormat_SetIntValue(exportFormat, OH_MD_KEY_MATRIX_COEFFICIENTS, OH_MatrixCoefficient::MATRIX_COEFFICIENT_BT709);
    OH_AVFormat_SetIntValue(exportFormat, OH_MD_KEY_TRANSFER_CHARACTERISTICS,
                            OH_TransferCharacteristic::TRANSFER_CHARACTERISTIC_BT709);
    OH_AVFormat_SetIntValue(exportFormat, OH_MD_KEY_RANGE_FLAG, false);
    OH_AVFormat_SetIntValue(exportFormat, OH_MD_KEY_WIDTH, outputWidth);
    OH_AVFormat_SetIntValue(exportFormat, OH_MD_KEY_HEIGHT, outputHeight);
    
    // 根据帧率和分辨率确定码流
    double framerate;
    OH_AVFormat_GetDoubleValue(exportFormat, OH_MD_KEY_FRAME_RATE, &framerate);
    LOGI("Editor::PrepareExportEngine original framerate %{public}f", framerate);
    int64_t bitrate;
    OH_AVFormat_GetLongValue(exportFormat, OH_MD_KEY_BITRATE, &bitrate);
    LOGI("Editor::PrepareExportEngine original bitrate %{public}d", bitrate);
    // 根据帧率设置基础码流，30fps为1000kbps，60fps为1400kbps
    if (std::abs(framerate-30) < 1) {
        // 30fps 设置 1000kbps
        bitrate = 1000000;
        LOGI("Editor::PrepareExportEngine video is 30fps, set base bitrate %{public}d", bitrate);
    }
    if (std::abs(framerate-60) < 1) {
        // 60fps 设置 1400kbps
        bitrate = 1400000;
        LOGI("Editor::PrepareExportEngine video is 60fps, set base bitrate %{public}d", bitrate);
    }
    if (bitrate != 1000000 && bitrate != 1400000) {
        // 帧率非60fps和30fps的视频以30fps为基础scale
        LOGI("Editor::PrepareExportEngine video is not 60fps or 30fps, scale bitrate");
        double ratio = static_cast<double>(outputHeight) * outputWidth / (1280 * 720);
        double rawBitrate  = ratio * 1000000 * (framerate/30) ;
        bitrate = static_cast<int64_t>(std::max(0.8*1000000, std::min(rawBitrate, 1.5*1000000)));
        LOGI("Editor::PrepareExportEngine video is not 60fps or 30fps, scaled bitrate is %{public}d", bitrate);
    } else {
        // 60fps和30fps的视频如果分辨率比720p低按各自基准scale。
        if (std::min(outputHeight, outputWidth) < 720) {
            // 如果视频分辨率低降低码流
            bitrate = static_cast<double>(outputHeight) * outputWidth / (1280 * 720) * bitrate;
            LOGI("Editor::PrepareExportEngine video is 60fps or 30fps, output scaled bitrate is %{public}d", bitrate);
        }
        LOGI("Editor::PrepareExportEngine video is 60fps or 30fps, output bitrate is %{public}d", bitrate);
    }
    OH_AVFormat_SetLongValue(exportFormat, OH_MD_KEY_BITRATE, bitrate);
    OH_AVFormat_SetStringValue(exportFormat, OH_MD_KEY_CODEC_MIME, "video/hevc");
    
    uint64_t exportDuration = mainVideo->GetDuration();
    LOGI("Editor::PrepareExportEngine avFormat export duration is %{public}d us.", 
        exportDuration
    );
    
    // 旋度设为0，渲染里把视频实际旋转了。
    OH_AVFormat_SetIntValue(exportFormat, OH_MD_KEY_ROTATION, 0);
        
    // Create encoder for export
    AVEncodeParam encodeParam;
    encodeParam.audioTrunkFormat = decoderEngine->GetAudioFormat();
    
    // 设置音频编码的avFormat参数
    OH_AVFormat_SetIntValue(encodeParam.audioTrunkFormat, OH_MD_KEY_AUD_SAMPLE_RATE, 44100);
    OH_AVFormat_SetIntValue(encodeParam.audioTrunkFormat, OH_MD_KEY_AUDIO_SAMPLE_FORMAT, OH_BitsPerSample::SAMPLE_S16LE); 
    OH_AVFormat_SetIntValue(encodeParam.audioTrunkFormat, OH_MD_KEY_AUD_CHANNEL_COUNT, 2);
    OH_AVFormat_SetLongValue(encodeParam.audioTrunkFormat, OH_MD_KEY_CHANNEL_LAYOUT, OH_AudioChannelLayout::CH_LAYOUT_STEREO); 
    OH_AVFormat_SetStringValue(encodeParam.audioTrunkFormat, OH_MD_KEY_CODEC_MIME, OH_AVCODEC_MIMETYPE_AUDIO_AAC); 
    OH_AVFormat_SetLongValue(encodeParam.audioTrunkFormat, OH_MD_KEY_BITRATE, 96000);
    
    if (m_inVideoFormat == nullptr) {
        LOGE("Editor::PrepareExportEngine export format is nullptr.");
        return VEditorStatus::STATUS_ERROR;
    }
    encodeParam.videoTrunkFormat = exportFormat;
    int32_t resultFd = open(savePath.c_str(), O_WRONLY | O_CREAT | O_TRUNC,
                        S_IRUSR | S_IWUSR | // owner: rw-
                            S_IRGRP |       // group: r--
                            S_IROTH         // other: r-- // 文件权限：-rw-r--r--
    );
    
    if (resultFd == -1) {
        LOGE("Editor::PrepareExportEngine Open file to save failed");
        return VEditorStatus::STATUS_ERROR;
    }

    TrackFd(resultFd);
    encodeParam.muxerParam.targetFileFd = resultFd;
    encodeParam.muxerParam.rotation = 0;
    LOGD("Editor::PrepareExportEngine Open fd is %{public}d.", encodeParam.muxerParam.targetFileFd);
    
    std::shared_ptr<IAVEncoderEngine> encoderEngine = IAVEncoderEngine::Create(encodeParam, exportEncoderCallback);
    if (encoderEngine == nullptr) {
        LOGE("Editor::PrepareExportEngine create encoder engine failed.");
        return VEditorStatus::STATUS_ERROR;
    }
    status = encoderEngine->Init();
    if(status == AVError::AV_ERROR) {
            LOGE("Editor::PrepareExportEngine encoder engine init failed.");
            return VEditorStatus::STATUS_ERROR;
    }
    
    // 编码的格式设置成720p
    (void)OH_NativeWindow_NativeWindowHandleOpt(encoderEngine->GetVideoInputWindow(), SET_BUFFER_GEOMETRY,
                                            static_cast<int>(outputWidth),
                                            static_cast<int>(outputHeight));
    

    m_renderEngine->SetViewParams(viewParams);
    
    int32_t renderEngineStatus;
    renderEngineStatus = m_renderEngine->SetOutSurface(encoderEngine->GetVideoInputWindow());
    LOGD("Editor:: render engine status is %{public}d", renderEngineStatus);
    
    m_bufferQueue = encoderEngine->GetAudioInputBufferQueue();
    if (m_bufferQueue == nullptr) {
        LOGE("Editor::PrepareExportEngine buffer Queue is nullptr.");
        return VEditorStatus::STATUS_ERROR;
    }

    status = decoderEngine->SetAudioOutputBufferQueue(m_bufferQueue);
    if(status == AVError::AV_ERROR) {
        LOGE("Editor::PrepareExportEngine set decoder output buffer queue failed.");
        return VEditorStatus::STATUS_ERROR;
    }
    // 转换成毫秒
    uint64_t playDuration = exportDuration / 1000;
    LOGI("Editor::PrepareExportEngine Set PlayDuration is %{public}d ms", 
        playDuration
    );
    decoderEngine->SetPlayDuration(playDuration); // 这里视频长度单位是微秒，接口要求毫秒
    m_exportEngine = decoderEngine;
    m_encoderEngine = encoderEngine;
    m_isExportReady = true;
    
    OH_AVFormat_Destroy(encodeParam.videoTrunkFormat); // 销毁给编码的avFormat
    return VEditorStatus::STATUS_OK;
}

VEditorStatus Editor::PreparePreviewEngine(int32_t fd)
{   
    LOGI("Editor::PreparePreviewEngine.");
    LOGD("Editor::PreparePreviewEngine fd is %{public}d.", fd);
    // 无主视频不启动.
    std::shared_ptr<VideoAsset> mainVideo = m_timeline->GetMainVideo();
    if (mainVideo == nullptr) {
        LOGE("Editor::PreparePreviewEngine no mainVideo.");
        return VEditorStatus::STATUS_ERROR;
    }
    // Create Decoder
    std::shared_ptr<IAVDecoderEngine> decoderEngine = IAVDecoderEngine::Create(fd, previewDecoderCallback);
    if (decoderEngine == nullptr) {
        LOGE("Editor::PreparePreviewEngine Create preview decoder engine failed.");
        return VEditorStatus::STATUS_ERROR;
    }
    m_previewEngine = decoderEngine;
    return VEditorStatus::STATUS_OK;
}

void Editor::MuteVideo(bool muted)
{
    LOGI("Editor::MuteVideo %{public}d.", muted);
    std::shared_ptr<VideoAsset> mainVideo = m_timeline->GetMainVideo();
    if(mainVideo == nullptr) {
        LOGE("Editor::MuteVideo main video is nullptr.");
        return;
    }
    m_previewEngine->AudioMute(muted); 
    mainVideo->SetIsMuted(muted);
}

void Editor::OnPlay(int64_t pts)
{

    if (m_firstFrame == false) {
        LOGI("Editor::OnPlay get VideoFormat");
        m_inVideoFormat = OH_AVFormat_Create();
        OH_AVFormat_Copy(m_inVideoFormat, m_previewEngine->GetVideoFormat());

        m_firstFrame = true;
    }
    if ((pts + 60000) >= m_timeline->GetVideoEndPos()) {
        LOGI("Editor::OnPlay Trigger onPlay play from start. pts is %{public}d, end pos is %{public}d.", 
             pts, 
             m_timeline->GetVideoEndPos()
        );

        // 这里新起一个线程seek，不然会死锁。
        std::thread t([this]() { PlayFromStart(); });
        t.detach();
    }
}

void Editor::OnExport(int64_t pts)
{   
    auto mainVideo = m_timeline->GetMainVideo();
    if(mainVideo == nullptr) {
        LOGE("Editor::OnExport main video is nullptr.");
        return;
    }
    auto duration = mainVideo->GetDuration();
    LOGD("Editor::OnExport pts is %{public}d, duration is %{public}d.", pts, duration);
    if (m_exportSendProgress != nullptr) {
        
        // 这里的pts和duration只用于反馈进度，不用于判断导出结束。转换导出视频帧率时需要转换duration。
        float progress = float(pts)/float(duration); 
        
        // 只有进度增加超过10%才通知前端
        if (progress > m_progress + 0.05) {
            m_progress = progress;
            int32_t* data = (int32_t*)malloc(sizeof(int32_t)); // 这个内存在js线程释放。
            int32_t progressPercent = static_cast<int32_t>(progress * 100 + 0.5f);
            progressPercent = progressPercent > 100 ? 100:progressPercent; // 屏蔽非法值
            *data = progressPercent;
            LOGD("Editor::OnExport progress is %{public}d.", *data);
            LOGD("Editor::OnExport pts is %{public}d, duration is %{public}d.", pts, duration);
            napi_call_threadsafe_function(m_exportSendProgress, data, napi_tsfn_nonblocking);
        }
    }
    
    if (isDecoderStopped && encoderFrameCount + 10 >= decoderFrameCount){ // 这里容忍丢5帧
        LOGI("Editor::OnExport decoder stopped and encoder received enough frames %{public}d. Encoder pts is %{public}d", 
             encoderFrameCount.load(),
             pts
        );
        if (m_sendEos == false) {
            LOGI("Editor::OnExport Trigger onExport send eos.");
            m_sendEos = true;
            
            std::thread t([this]() {
                m_encoderEngine->SendEOS();
                m_exportEngine->Stop();
                if (m_exportSendEnd) {
                    napi_call_threadsafe_function(m_exportSendEnd, nullptr, napi_tsfn_nonblocking);
                }
            });
            t.detach();
        }
    }
}

void Editor::SetPreviewWindow(OHNativeWindow *window)
{
    LOGI("Editor::SetPreviewWindow.");
    if (window == nullptr || m_previewEngine == nullptr) {
        LOGE("Editor::SetPreviewWindow window or engine is nullptr .");
        return;
    }
    m_previewWindow = window;
    m_previewEngine->SetVideoOutputWindow(m_previewWindow);
    m_previewEngine->Init();
        
    // 创建视频对应的解码引擎并且初始化后才能拿到视频信息，所以在这里设置
    OH_AVFormat *format = m_previewEngine->GetVideoFormat();
        if (format == nullptr) {
            LOGE("Editor::SetPreviewWindow no Video format.");
            return;
        }
    int64_t originalDuration = 0;
    int32_t width, height;
    int32_t rotation;
    
    // auto start = std::chrono::high_resolution_clock::now();
    originalDuration = m_previewEngine->GetVideoDuration();
    // auto end = std::chrono::high_resolution_clock::now();
    // auto us = std::chrono::duration_cast<std::chrono::microseconds>(end - start);
    // LOGD("Editor::SetPreviewWindow get original video duration time cost %{public}d us.", us);
    
    if(originalDuration <= 0) {
        LOGE("Editor::SetPreviewWindow get video duration failed.");
        return;
    }
    
    OH_AVFormat_GetIntValue(format, OH_MD_KEY_HEIGHT, &height);
    OH_AVFormat_GetIntValue(format, OH_MD_KEY_WIDTH, &width);
    OH_AVFormat_GetIntValue(format, OH_MD_KEY_ROTATION, &rotation);
    LOGD("Editor::SetPreviewWindow Set rotation is %{public}d.", rotation);
    
    // 设置视频宽高，后面在SetCanvasSize时才能拿到宽高比
    std::shared_ptr<VideoAsset> mainVideo = m_timeline->GetMainVideo();
    if (mainVideo == nullptr) {
        LOGE("Editor::SetPreviewWindow no mainVideo.");
        return;
    }
    mainVideo->SetWidth(width);
    LOGD("Editor::SetPreviewWindow Set video width %{public}d.", width);
    mainVideo->SetHeight(height);
    LOGD("Editor::SetPreviewWindow Set video height %{public}d.", height);
    mainVideo->SetRotation(rotation);
    mainVideo->SetOriginalDuration(static_cast<uint64_t>(originalDuration));
    LOGD("Editor::SetPreviewWindow Set original video duration %{public}d.", originalDuration);
}

void Editor::RegisterExportCallback(napi_threadsafe_function onProgress, napi_threadsafe_function onEnd)
{
    LOGI("Editor::RegisterExportCallback.");
    m_exportSendEnd = onEnd;
    m_exportSendProgress = onProgress;
}