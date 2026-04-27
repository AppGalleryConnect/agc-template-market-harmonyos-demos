import { speechRecognizer } from '@kit.CoreSpeechKit';

// 语音识别
export class SpeechRecognizer {
  private engineParams: speechRecognizer.CreateEngineParams = {
    online: 1,
    language: 'zh-CN',
    extraParams: { 'locate': 'CN', 'recognizerMode': 'short' }
  };
  private speechEngine?: speechRecognizer.SpeechRecognitionEngine;
  private sessionId: string = 'SpeechRecognizer_' + Date.now();

  // 初始化
  public async intiEngine() {
    try {
      this.speechEngine = await speechRecognizer.createEngine(this.engineParams);
    } catch (err) {
    }
  }

  // 开始语音识别，并监听语音，返回结果
  public start(callback: (srr: speechRecognizer.SpeechRecognitionResult) => void = () => {}) {
    this.setListener(callback);
    this.startListening();
  }

  // 完成识别
  public stop() {
    this.speechEngine?.finish(this.sessionId);
  }

  // 释放语音识别引擎资源
  public shutdown() {
    this.speechEngine?.shutdown();
  }

  // 开始语音识别
  private startListening() {
    let recognizerParams: speechRecognizer.StartParams = {
      sessionId: this.sessionId,
      extraParams: {
        vadBegin: 500,
        vadEnd: 10000,
        recognitionMode: 0,
        maxAudioDuration: 60000,
      },
      audioInfo: {
        soundChannel: 1,
        sampleBit: 16,
        audioType: 'pcm',
        sampleRate: 16000,
      },
    };
    this.speechEngine?.startListening(recognizerParams);
  }

  // 监听语音，返回结果
  private setListener(callback: (result: speechRecognizer.SpeechRecognitionResult) => void = () => {}) {
    let listener: speechRecognizer.RecognitionListener = {
      onStart(_sessionId: string, _eventMessage: string) {
      },
      onEvent(_sessionId: string, _eventCode: number, _eventMessage: string) {
      },
      onResult(_sessionId: string, result: speechRecognizer.SpeechRecognitionResult) {
        callback && callback(result);
      },
      onComplete(_sessionId: string, _eventMessage: string) {
      },
      onError(_sessionId: string, _errorCode: number, _errorMessage: string) {
      },
    };
    this.speechEngine?.setListener(listener);
  }
}