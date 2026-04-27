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
import { UtilLog } from '@hw-agconnect/util-log';
import { PersistenceV2 } from '@kit.ArkUI';
import { speechRecognizer } from '@kit.CoreSpeechKit';
import { BusinessError, pasteboard } from '@kit.BasicServicesKit';
import { util } from '@kit.ArkTS';
import { fileIo as fs, picker } from '@kit.CoreFileKit';
import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';
import { FileCapture } from '../util/FileCapture';
import { RouterMap, getInstance } from '../util/Route';
import { PlayUtil } from '../util/PlayUtil';
import { createFd } from '../util/ConvertUtil';
import { Logger } from '../util/Logger';
import { MAX_DURATION } from '../constant/Index';
import { MyAudio, AudioInfo, FileInfo } from '../model/Index';


const TAG = '[ConvertPageVM]';


@ObservedV2
export class ConvertPageVM {
  @Trace isRefresh: boolean = false;
  // 我的录音
  @Trace myAudio: MyAudio = PersistenceV2.connect(MyAudio, () => new MyAudio())!;
  // 当前录音
  @Trace curAudio: AudioInfo = new AudioInfo();
  // 录音时长：单位秒
  @Trace duration: number = 1;
  // 当前播放位置
  @Trace curTime: number = 0;
  // 是否正在播放
  @Trace isPlaying: boolean = false;
  // 结果文本
  @Trace generatedText: string = '';
  // 过程文本
  @Trace progressText: string = '';
  // 是否识别完成
  @Trace isFinal: boolean = false;
  // 会话id
  @Trace sessionId: string = '';
  // 语音识别引擎
  asrEngine: speechRecognizer.SpeechRecognitionEngine | null = null;
  // 播放工具类
  private playUtil: PlayUtil = new PlayUtil();
  // 文件流采集
  private mFileCapture = new FileCapture();
  private static _instance: ConvertPageVM;

  public static get instance() {
    if (!ConvertPageVM._instance) {
      ConvertPageVM._instance = new ConvertPageVM();
    }
    return ConvertPageVM._instance;
  }

  public getRouteParam() {
    const id: string = getInstance().getParamByName(RouterMap.CONVERT)[0] as string;
    this.curAudio = this.myAudio.getAudioById(id);
    this.isRefresh = false;
  }

  // 初始化播放器
  public initPlayer() {
    this.playUtil.onCompleted = this.onCompleted;
    this.playUtil.onPrepared = this.onPrepared;
    this.playUtil.onTimeUpdate = this.onTimeUpDate;
    this.playUtil.onSeekDone = this.onSeekDone;
    this.curTime = 0;
    this.generatedText = '';
    this.playUtil.avPlayerUrlInit(this.curAudio.filePath);
  }

  public play() {
    this.playUtil.avPlay();
    this.isPlaying = true;
  }

  // 暂停
  public pause() {
    this.playUtil.avPause();
    this.isPlaying = false;
  }

  // 实例销毁
  public released() {
    this.playUtil.avReleased();
    this.isPlaying = false;
  }

  // 跳转指定时间
  public async seek(targetTime: number) {
    if (this.isPlaying) {
      this.playUtil.avSeek(targetTime);
    } else {
      this.playUtil.avSeek(targetTime);
      this.isPlaying = true;
    }

  }


  // 创建引擎，通过callback形式返回
  public async createByCallback() {
    // 设置创建引擎参数
    let extraParam: Record<string, Object> = { 'locate': 'CN', 'recognizerMode': 'long' };
    let initParamsInfo: speechRecognizer.CreateEngineParams = {
      language: 'zh-CN',
      online: 1,
      extraParams: extraParam,
    };
    // 调用createEngine方法
    return new Promise<void>((resolve, reject) => {
      try {
        speechRecognizer.createEngine(initParamsInfo, (err: BusinessError, speechRecognitionEngine:
          speechRecognizer.SpeechRecognitionEngine) => {
          if (!err) {
            Logger.info(TAG, 'succeeded in creating engine.');
            // 接收创建引擎的实例
            this.asrEngine = speechRecognitionEngine;
            this.setListener();
            resolve();
          } else {
            Logger.error(TAG, `Failed to create engine. Message: ${err.message}.`);
            reject();
          }
        });
      } catch (e) {
        UtilLog.error(`createEngine failed with error ${JSON.stringify(e)}`);
      }
    });
  }

  // 写音频流
  public async audioToText() {
    if (this.mFileCapture.isIsWriting()) {
      promptAction.showToast({ message: '正在识别，请稍后！' });
      this.isRefresh = false;
      return;
    }
    if (this.asrEngine) {
      try {
        let audioParam: speechRecognizer.AudioInfo = {
          audioType: 'pcm',
          sampleRate: 16000,
          soundChannel: 1,
          sampleBit: 16,
        };
        if (this.sessionId) {
          this.asrEngine.cancel(this.sessionId);
          this.mFileCapture.stop();
        }
        this.sessionId = util.generateRandomUUID(false);
        let recognizerParams: speechRecognizer.StartParams = {
          sessionId: this.sessionId,
          audioInfo: audioParam,
          extraParams: {
            maxAudioDuration: MAX_DURATION * 1000, // 最长支持的语音识别音频长度 ms
          },
        };
        this.asrEngine.startListening(recognizerParams);
        let data: ArrayBuffer;
        this.mFileCapture.setFilePath(this.curAudio.pcmPath);
        this.mFileCapture.init((dataBuffer: ArrayBuffer) => {
          data = dataBuffer;
          const uint8Array: Uint8Array = new Uint8Array(data);
          this.asrEngine?.writeAudio(this.sessionId, uint8Array);
        });
        await this.mFileCapture.start();
        this.mFileCapture.release();
      } catch (err) {
        Logger.info(JSON.stringify(err));
      }
    }
  }

  // 睡眠
  public sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  public shutdown() {
    if (this.asrEngine) {
      // 释放引擎
      try {
        this.asrEngine.shutdown();
        this.asrEngine = null;
        // 结束文件流推送
        this.mFileCapture.release();
        this.sessionId = '';
      } catch (err) {
        Logger.info(JSON.stringify(err));
      }
    }
    // 清空结果文本
    this.generatedText = '';
    this.progressText = '';
    this.isFinal = false;
  }

  public toCopy() {
    try {
      if (this.generatedText || this.progressText) {
        const pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN,
          this.isFinal ? this.generatedText : this.generatedText + this.progressText);
        pasteboard.getSystemPasteboard().setData(pasteData).then(() => {
          promptAction.showToast({ message: '复制成功' });
        }).catch((err: BusinessError) => {
          promptAction.showToast({ message: '复制失败' });
        });
      } else {
        promptAction.showToast({ message: '暂无内容!' });
      }
    } catch (e) {
      UtilLog.error(`toCopy error ${JSON.stringify(e)}`)
    }
  }

  async saveText() {
    let uris: string = '';
    const fileInfo: FileInfo = createFd('txt');
    try {
      const documentSaveOptions = new picker.DocumentSaveOptions(); // 创建文件管理器保存选项实例
      documentSaveOptions.newFileNames =
        [fileInfo.fileName]; // 保存文件名（可选），方括号里的文件名自定义，每次不能重复，设备里已有这个文件的话，名字就需要改个不一样的，不然接口会报错
      const documentViewPicker = new picker.DocumentViewPicker();
      try {
        let documentSaveResult = await documentViewPicker.save(documentSaveOptions);
        if (documentSaveResult !== undefined) {
          uris = documentSaveResult[0];
          Logger.info('save to file succeed and uris are:' + uris);
        }
      } catch (error) {
        let err: BusinessError = error as BusinessError;
        Logger.error(`save failed, code is ${err.code}, message is ${err.message}`);
      }
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      Logger.info(JSON.stringify(err));
    }
    let file: fs.File | null = null;
    let file2: fs.File | null = null;
    try {
      file = fs.openSync(fileInfo.filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      const content = this.isFinal ? this.generatedText : this.generatedText + this.progressText;
      fs.writeSync(file.fd, content);
      file2 = fs.openSync(uris + '', fs.OpenMode.READ_WRITE);
      fs.copyFileSync(file.fd, file2.fd);
      promptAction.showToast({ message: '导出成功！' });
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      Logger.error(`save failed, code is ${err.code}, message is ${err.message}`);
    } finally {
      if (file) {
        fs.closeSync(file);
        fs.unlinkSync(file.path);
      }
      if (file2) {
        fs.closeSync(file2);
      }
    }
  }

  // 准备完成
  private onPrepared = (duration: number) => {
    this.duration = duration;
    if (this.duration > MAX_DURATION) {
      promptAction.showToast({ message: `该功能仅支持识别${MAX_DURATION}秒以内的音频，超出部分无法正常识别！` });
    }
  };
  // 播放完成的回调
  private onCompleted = () => {
    this.isPlaying = false;
    this.curTime = 0;
  };
  // 播放时间更新的回调
  private onTimeUpDate = (time: number) => {
    this.curTime = time;
  };
  // 跳转完成的回调
  private onSeekDone = (time: number) => {
    this.curTime = time;
  };

  // 设置回调
  private setListener() {
    // 创建回调对象
    const setListener: speechRecognizer.RecognitionListener = {
      // 开始识别成功回调
      onStart: (sessionId: string, eventMessage: string) => {
        this.generatedText = '';
        this.progressText = '';
        Logger.info(TAG, `onStart, sessionId: ${sessionId} eventMessage: ${eventMessage}`);
      },
      // 事件回调
      onEvent(sessionId: string, eventCode: number, eventMessage: string) {
        Logger.info(TAG, `onEvent, sessionId: ${sessionId} eventCode: ${eventCode} eventMessage: ${eventMessage}`);
      },
      // 识别结果回调，包括中间结果和最终结果
      onResult: (sessionId: string, result: speechRecognizer.SpeechRecognitionResult) => {
        Logger.info(TAG, `onResult, sessionId: ${sessionId} result: ${JSON.stringify(result)}`);
        this.isRefresh = false;
        if (result.isFinal) {
          this.generatedText += result.result + '\n';
        }
        this.progressText = result.result;
        this.isFinal = result.isFinal;
      },
      // 识别完成回调
      onComplete(sessionId: string, eventMessage: string) {
        Logger.info(TAG, `onComplete, sessionId: ${sessionId} eventMessage: ${eventMessage}`);
      },
      // 错误回调，错误码通过本方法返回
      onError(sessionId: string, errorCode: number, errorMessage: string) {
        Logger.error(TAG, `onError, sessionId: ${sessionId} errorCode: ${errorCode} errorMessage: ${errorMessage}`);
      },
    };
    if (this.asrEngine) {
      // 设置回调
      this.asrEngine.setListener(setListener);
    }
  };
}