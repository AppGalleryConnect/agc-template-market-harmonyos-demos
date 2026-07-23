import { speechRecognizer } from '@kit.CoreSpeechKit';

export class SpeechRecognizer {
  private engineParams: speechRecognizer.CreateEngineParams = {
    language: 'zh-CN',
    online: 1,
    extraParams: { 'locate': 'CN', 'recognizerMode': 'long' }
  };
  private asrEngine?: speechRecognizer.SpeechRecognitionEngine;
  private sessionId: string = 'SpeechRecognizer_' + Date.now();

  public async initEngine() : Promise<boolean> {
    try {
      this.asrEngine = await speechRecognizer.createEngine(this.engineParams);
      return true;
    }catch (e) {
      console.log(e);
      return false;
    }
  }

  public start(callback: (srr?: speechRecognizer.SpeechRecognitionResult, isFinish?: boolean,
    error?: Error) => void = () => {
  }) {
    this.setListener(callback);
    this.startListening();
  }

  public stop() {
    this.asrEngine?.finish(this.sessionId);
  }

  public shutdown() {
    this.asrEngine?.shutdown();
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
    this.asrEngine?.startListening(recognizerParams);
  }

  private setListener(callback: (srr?: speechRecognizer.SpeechRecognitionResult, isFinish?: boolean,
    error?: Error) => void = () => {
  }) {
    let listener: speechRecognizer.RecognitionListener = {
      onStart(sessionId: string, eventMessage: string) {
      },
      onEvent(sessionId: string, eventCode: number, eventMessage: string) {
      },
      onResult(sessionId: string, result: speechRecognizer.SpeechRecognitionResult) {
        callback && callback(result);
      },
      onComplete(sessionId: string, eventMessage: string) {
        callback && callback(undefined, true);
      },
      onError(sessionId: string, errorCode: number, errorMessage: string) {
        callback && callback(undefined, true, new Error(errorMessage));
      },
    };
    this.asrEngine?.setListener(listener);
  }
}