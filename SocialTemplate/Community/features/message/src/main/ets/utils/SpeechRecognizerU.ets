import { speechRecognizer } from '@kit.CoreSpeechKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN: number = 0x0000
const TAG: string = 'SpeechRecognizerU'

// 语音转换文字
export class SpeechRecognizerU {
  // 创建引擎，通过callback形式返回
  asrEngine: speechRecognizer.SpeechRecognitionEngine | undefined = undefined;
  covertCallback: (result: string) => void = (result: string) => {}

  constructor(callback: (result: string) => void) {
    this.covertCallback = callback

    // 设置创建引擎参数
    let extraParam: Record<string, Object> = { 'locate': 'CN', 'recognizerMode': 'short' };
    let initParamsInfo: speechRecognizer.CreateEngineParams = {
      language: 'zh-CN',
      online: 1,
      extraParams: extraParam
    };

    try {
      speechRecognizer.createEngine(initParamsInfo, (err: BusinessError, speechRecognitionEngine:
        speechRecognizer.SpeechRecognitionEngine) => {
        if (!err) {
          hilog.info(DOMAIN, TAG, '%{public}s', 'Succeeded in creating engine.');
          // 接收创建引擎的实例
          this.asrEngine = speechRecognitionEngine;
        } else {
          // 无法创建引擎时返回错误码1002200001，原因：语种不支持、模式不支持、初始化超时、资源不存在等导致创建引擎失败
          // 无法创建引擎时返回错误码1002200006，原因：引擎正在忙碌中，一般多个应用同时调用语音识别引擎时触发
          // 无法创建引擎时返回错误码1002200008，原因：引擎已被销毁
          hilog.error(DOMAIN, TAG, '%{public}s', `Failed to create engine. Code: ${err.code}, message: ${err.message}.`);
        }
      })
    } catch (e) {
      hilog.error(DOMAIN, TAG, '%{public}s', `Failed to create engine. Code: ${e.code}, message: ${e.message}.`);
    }
  }

  // 设置回调
  setListener() {
    // 创建回调对象
    let setListener: speechRecognizer.RecognitionListener = {
      // 开始识别成功回调
      onStart: () => {
      },
      // 事件回调
      onEvent: () => {
      },
      // 识别结果回调，包括中间结果和最终结果
      onResult: (sessionId: string, result: speechRecognizer.SpeechRecognitionResult) => {
        hilog.info(DOMAIN, TAG, '%{public}s', `onResult sessionId: ${sessionId} result: ${result.result}`);
        if (result.result) {
          this.covertCallback(result.result)
        }
      },
      // 识别完成回调
      onComplete: () => {
      },
      onError: (sessionId: string, errorCode: number, errorMessage: string) => {
        hilog.error(DOMAIN, TAG, '%{public}s',
          `onError sessionId: ${sessionId} errorCode: ${errorCode} errorMessage: ${errorMessage}`);
      }
    };
    try {
      // 设置回调
      this.asrEngine?.setListener(setListener);
      hilog.error(DOMAIN, TAG, '%{public}s', `已设置监听回调`);
    } catch (e) {
      hilog.error(DOMAIN, TAG, '%{public}s', `设置监听回调失败`);
    }
  };

  // 写音频流
  async writeAudio(sessionId: string, filePath: string) {
    this.startListeningForWriteAudio(sessionId);
    let file = fs.openSync(filePath, fs.OpenMode.READ_WRITE);
    try {
      let buf: ArrayBuffer = new ArrayBuffer(1280);
      let offset: number = 0;
      while (1280 === fs.readSync(file.fd, buf, {
        offset: offset
      })) {
        let uint8Array: Uint8Array = new Uint8Array(buf);
        this.asrEngine?.writeAudio(sessionId, uint8Array);
        await this.countDownLatch(1);
        offset = offset + 1280;
      }
    } catch (err) {
      hilog.error(DOMAIN, TAG, '%{public}s', `Failed to read from file. Code: ${err.code}, message: ${err.message}.`);
    } finally {
      if (null !== file) {
        this.asrEngine?.finish(sessionId);
        fs.closeSync(file);
      }
    }
  }

  startListeningForWriteAudio(sessionId: string) {
    // 设置开始识别的相关参数
    let recognizerParams: speechRecognizer.StartParams = {
      sessionId: sessionId,
      audioInfo: {
        audioType: 'pcm',
        sampleRate: 16000,
        soundChannel: 1,
        sampleBit: 16
      } //audioInfo参数配置请参考AudioInfo
    }
    // 调用开始识别方法
    this.asrEngine?.startListening(recognizerParams)
  };

  // 计时
  async countDownLatch(count: number) {
    while (count > 0) {
      await this.sleep(40);
      count--;
    }
  }

  // 睡眠
  sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}