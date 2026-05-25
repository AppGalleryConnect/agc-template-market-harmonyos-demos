import { speechRecognizer } from '@kit.CoreSpeechKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x00ff
const TAG = '[SpeechRecognizer]'

export class SpeechRecognizer {
  // 设置创建引擎参数
  private engineParams: speechRecognizer.CreateEngineParams = {
    language: 'zh-CN',
    online: 1,
    extraParams: { 'locate': 'CN', 'recognizerMode': 'long' }
  };
  private asrEngine?: speechRecognizer.SpeechRecognitionEngine;
  private sessionId: string = '';

  public async intiEngine() {
    try {
      this.sessionId = 'SpeechRecognizer_' + Date.now();
      this.asrEngine = await speechRecognizer.createEngine(this.engineParams);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to create engine. Code is ${error.code}, message is ${error.message}`);
    }
  }

  public shutdown() {
    this.asrEngine?.shutdown();
  }

  public start(callback: (srr: speechRecognizer.SpeechRecognitionResult) => void = () => {
  }) {
    this.setListener(callback);
    this.startListening();
  }

  public stop() {
    try {
      this.asrEngine?.finish(this.sessionId);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to stop engine. Code is ${error.code}, message is ${error.message}`);
    }
  }

  private startListening() {
    let recognizerParams: speechRecognizer.StartParams = {
      sessionId: this.sessionId,
      audioInfo: {
        audioType: 'pcm',
        sampleRate: 16000,
        soundChannel: 1,
        sampleBit: 16
      },
      extraParams: {
        recognitionMode: 0,
        maxAudioDuration: 60000,
        vadBegin: 500,
        vadEnd: 10000,
      }
    };
    try {
      this.asrEngine?.startListening(recognizerParams);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to start listening. Code is ${error.code}, message is ${error.message}`);
    }
  }

  private setListener(callback: (srr: speechRecognizer.SpeechRecognitionResult) => void = () => {
  }) {
    // 创建回调对象
    let listener: speechRecognizer.RecognitionListener = {
      // 开始识别成功回调
      onStart(sessionId: string, eventMessage: string) {
      },
      // 事件回调
      onEvent(sessionId: string, eventCode: number, eventMessage: string) {
      },
      // 识别结果回调，包括中间结果和最终结果
      onResult(sessionId: string, result: speechRecognizer.SpeechRecognitionResult) {
        callback && callback(result);
      },
      // 识别完成回调
      onComplete(sessionId: string, eventMessage: string) {
      },
      // 错误回调，错误码通过本方法返回
      // 返回错误码1002200002，开始识别失败，重复启动startListening方法时触发
      onError(sessionId: string, errorCode: number, errorMessage: string) {
      },
    };
    this.asrEngine?.setListener(listener);
  }
}
