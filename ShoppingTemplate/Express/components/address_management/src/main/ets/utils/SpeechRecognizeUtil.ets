import { speechRecognizer } from '@kit.CoreSpeechKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { fileIo } from '@kit.CoreFileKit';


const TAG = '[SpeechRecognizeUtil]'

export class SpeechRecognizeUtil {
  // 创建引擎，通过callback形式返回
  asrEngine: speechRecognizer.SpeechRecognitionEngine | undefined = undefined;
  // 语音识别的文字
  message: string = '';
  // 录音文件的沙箱地址
  filePath: string = '';
  // 语音识别结果回调
  onResultCallback: (text: string) => void = () => {
  };
  // 语音识别完成回调
  onCompleteCallback: () => void = () => {
  };

  setResultCallback(callback: (text: string) => void) {
    this.onResultCallback = callback;
  }

  setCompleteCallback(callback: () => void) {
    this.onCompleteCallback = callback;
  }

  createSpeechEngine() {
    // 设置创建引擎参数
    let extraParam: Record<string, Object> = { 'locate': 'CN', 'recognizerMode': 'short' };
    let initParamsInfo: speechRecognizer.CreateEngineParams = {
      language: 'zh-CN',
      online: 1,
      extraParams: extraParam,
    };

    try {
      // 调用createEngine方法
      speechRecognizer.createEngine(initParamsInfo, (err: BusinessError, speechRecognitionEngine:
        speechRecognizer.SpeechRecognitionEngine) => {
        if (!err) {
          UtilLog.info(TAG, 'Succeeded in creating engine.');
          // 接收创建引擎的实例
          this.asrEngine = speechRecognitionEngine;
          this.setListener();
        } else {
          // 无法创建引擎时返回错误码1002200001，原因：语种不支持、模式不支持、初始化超时、资源不存在等导致创建引擎失败
          // 无法创建引擎时返回错误码1002200006，原因：引擎正在忙碌中，一般多个应用同时调用语音识别引擎时触发
          // 无法创建引擎时返回错误码1002200008，原因：引擎已被销毁
          UtilLog.error(TAG, `Failed to create engine. Code: ${err.code}, message: ${err.message}.`);
        }
      });
    } catch (e) {
      UtilLog.error(TAG, `createEngine fail. Code: ${e.code}, message: ${e.message}`);
    }
  }

  // 设置回调
  setListener() {
    // 创建回调对象
    let setListener: speechRecognizer.RecognitionListener = {
      // 开始识别成功回调
      onStart: (sessionId: string, eventMessage: string) => {
        UtilLog.info(TAG, `onStart sessionId: ${sessionId} eventMessage: ${eventMessage}`);
      },
      // 事件回调
      onEvent: (sessionId: string, eventCode: number, eventMessage: string) => {
        UtilLog.info(TAG,
          `onEvent sessionId: ${sessionId} eventCode: ${eventCode} eventMessage: ${eventMessage}`);
      },
      // 识别结果回调，包括中间结果和最终结果
      onResult: (sessionId: string, result: speechRecognizer.SpeechRecognitionResult) => {
        UtilLog.info(TAG, `onResult sessionId: ${sessionId} result: ${result.result}`);
        if (result.result) {
          this.message = result.result;
          this.onResultCallback(result.result);
        }
      },
      // 识别完成回调
      onComplete: (sessionId: string, eventMessage: string) => {
        // 返回识别结果
        this.onCompleteCallback();
        // 删除沙箱文件
        this.deleteAudio();
        UtilLog.info(TAG, `onComplete sessionId: ${sessionId} eventMessage: ${eventMessage}`);
      },
      onError: (sessionId: string, errorCode: number, errorMessage: string) => {
        // 删除沙箱文件
        this.deleteAudio();
        UtilLog.error(TAG,
          `onError sessionId: ${sessionId} errorCode: ${errorCode} errorMessage: ${errorMessage}`);
      },
    };
    try {
      // 设置回调
      this.asrEngine?.setListener(setListener);
      UtilLog.info(TAG, `已设置监听回调`);
    } catch (e) {
      UtilLog.error(TAG, `设置监听回调失败`);
    }
  };
  // 删除沙箱的录音文件
  deleteAudio(filePath: string = '') {
    try {
      const tempFilePath = filePath || this.filePath;
      let realPath = tempFilePath.replace('file://', '');
      if (fileIo.accessSync(realPath)) {
        fileIo.unlinkSync(realPath);
      }
    } catch (err) {
      UtilLog.error(TAG, '移除失败: ' + JSON.stringify(err));
    }
  }

  // 写音频流
  async writeAudio(sessionId: string, filename: string, context: Context) {
    this.message = '';
    this.startListeningForWriteAudio(sessionId);
    let path = context.cacheDir;
    let filePath = path + `/${filename}.pcm`;
    this.filePath = filePath;
    let file = fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE);
    try {
      let buf: ArrayBuffer = new ArrayBuffer(1280);
      let offset: number = 0;
      while (1280 === fileIo.readSync(file.fd, buf, {
        offset: offset,
      })) {
        let uint8Array: Uint8Array = new Uint8Array(buf);
        this.asrEngine?.writeAudio(sessionId, uint8Array);
        await this.countDownLatch(1);
        offset = offset + 1280;
      }
    } catch (err) {
      UtilLog.error(TAG, `Failed to read from file. Code: ${err.code}, message: ${err.message}.`);
    } finally {
      if (file) {
        this.asrEngine?.finish(sessionId);
        fileIo.closeSync(file);
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
        sampleBit: 16,
      }, //audioInfo参数配置请参考AudioInfo
    };
    // 调用开始识别方法
    this.asrEngine?.startListening(recognizerParams);
  };
  // 计时
  async countDownLatch(count: number) {
    while (count > 0) {
      await this.sleep(20);
      count--;
    }
  }
  // 睡眠
  sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}