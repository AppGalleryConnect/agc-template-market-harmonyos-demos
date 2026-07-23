import { PersistenceV2 } from '@kit.ArkUI';
import { textToSpeech } from '@kit.CoreSpeechKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from './Logger';
import { VoiceModel, VoicePackage, VoiceType } from '../types/Types';

const TAG = '[BroadCastUtil]';

@ObservedV2
export class BroadCastUtil {
  private static _voiceModel: VoiceModel =
    PersistenceV2.connect(VoiceModel, 'voiceModel', () => new VoiceModel())!;
  private static _ttsEngine: textToSpeech.TextToSpeechEngine | undefined;

  public static async getVoiceList() {
    let list: VoicePackage[] = [
      new VoicePackage($r('app.media.cn_female'), 0, '聆小珊女声', 423, 5, true),
      new VoicePackage($r('app.media.cn_female'), 13, '聆小珊女声', 423, 5, true),
      new VoicePackage($r('app.media.cn_male'), 21, '凌飞哲男声', 233, 5, true),
      new VoicePackage($r('app.media.us_female'), 8, '劳拉女声', 73, 4, true),
    ];

    const query = await BroadCastUtil._queryList();
    if (query.findIndex(info => info.person === BroadCastUtil._voiceModel.curVoice) === -1) {
      BroadCastUtil._voiceModel.curVoice = query[0].person;
    }
    list = list.filter(item => {
      const index = query.findIndex(info => info.person === item.type);
      if (index !== -1) {
        if (query[index].status) {
          item.installed = query[index].status === 'INSTALLED';
        }
        return true;
      }
      return false;
    })
    return list;
  }

  public static getCurVoiceType() {
    return BroadCastUtil._voiceModel.curVoice;
  }

  public static async downloadVoice(
    type: VoiceType,
    startCallBack: () => void,
    progressCallback: (progress: string) => void,
    completeCallback: () => void,
  ) {
    const list = await BroadCastUtil.getVoiceList();
    const voicePackage = list.find(voice => voice.type === type)!;
    if (voicePackage.installed) {
      Logger.info(TAG, 'Voice has already been downloaded.');
      return;
    }
    // 设置下载音色相关参数
    let voicesDownloadParams: textToSpeech.VoiceDownload = {
      requestId: Date.now().toString(),
      language: voicePackage.type === VoiceType.US_FEMALE ? 'en-US' : 'zh-CN',
      person: type,
      style: 'interaction-broadcast',
    };

    // 调用downloadVoice方法
    textToSpeech.downloadVoice(voicesDownloadParams,
      (error: BusinessError, downloadResponse: textToSpeech.DownloadResponse) => {
        if (error) {
          Logger.error(TAG, `Failed to download voice. code: ${error.code}, message: ${error.message}`);
          return;
        }
        if (!downloadResponse) {
          Logger.error('Failed to download voice. downloadResponse is null');
          return;
        }
        let requestId: string = downloadResponse.requestId;

        let startCallbackReal: Callback<string> = (info: string) => {
          // 下载开始回调
          Logger.info(TAG, `download voice start, requestId: ${requestId}, info:${info}}`);
          startCallBack();
        };
        let completeCallbackReal: Callback<textToSpeech.VoiceInfo> = (voiceInfo: textToSpeech.VoiceInfo) => {
          // 下载完成回调
          Logger.info(TAG, `download voice complete, requestId: ${requestId} voiceInfo: ${JSON.stringify(voiceInfo)}`);
          completeCallback();
          // 取消下载进度事件回调注册
          downloadResponse.off('start', startCallbackReal);
          downloadResponse.off('progress', progressCallback);
          downloadResponse.off('complete', completeCallbackReal);
        };
        // 注册下载开始事件回调
        downloadResponse.on('start', startCallbackReal);
        // 注册下载进度事件回调
        downloadResponse.on('progress', progressCallback);
        // 注册下载完成事件回调
        downloadResponse.on('complete', completeCallbackReal);
      });
  }

  private static async _createEngine() {
    let extraParam: Record<string, string> =
      { 'style': 'interaction-broadcast', 'locate': 'CN', 'name': 'ttsEngine' };
    let initParamsInfo: textToSpeech.CreateEngineParams = {
      language: BroadCastUtil._voiceModel.curVoice === VoiceType.US_FEMALE ? 'en-US' : 'zh-CN',
      person: BroadCastUtil._voiceModel.curVoice,
      online: 1,
      extraParams: extraParam,
    };

    let speakListener: textToSpeech.SpeakListener = {
      // 开始播报回调
      onStart(requestId: string, response: textToSpeech.StartResponse) {
        Logger.info(TAG, `onStart, requestId: ${requestId} response: ${JSON.stringify(response)}`);
      },
      // 完成播报回调
      onComplete(requestId: string, response: textToSpeech.CompleteResponse) {
        Logger.info(TAG, `onComplete, requestId: ${requestId} response: ${JSON.stringify(response)}`);
      },
      // 停止播报完成回调，调用stop方法并完成时会触发此回调
      onStop(requestId: string, response: textToSpeech.StopResponse) {
        Logger.info(TAG, `onStop, requestId: ${requestId} response: ${JSON.stringify(response)}`);
      },
      // 错误回调，播报过程发生错误时触发此回调
      // 未创建引擎时调用speak方法时返回错误码1003400007，合成及播报失败
      // 连续调用两次speak，第二次speak会返回错误码1003400006，服务正忙碌
      onError(requestId: string, errorCode: number, errorMessage: string) {
        Logger.error(TAG, `onError, requestId: ${requestId} errorCode: ${errorCode} errorMessage: ${errorMessage}`);
      },
    };

    try {
      BroadCastUtil._ttsEngine = await textToSpeech.createEngine(initParamsInfo);
      BroadCastUtil._ttsEngine.setListener(speakListener);
      Logger.info(TAG, 'Succeeded in creating engine.');
    } catch (err) {
      // 创建引擎失败时返回错误码1003400005，可能原因：引擎不存在、资源不存在、创建引擎超时
      Logger.error(TAG, `Failed to create engine. Code: ${err.code}, message: ${err.message}.`);
    }
  }

  public static async speak(text: string) {
    if (!BroadCastUtil._ttsEngine) {
      await BroadCastUtil._createEngine();
    }
    BroadCastUtil.stop();
    // 设置播报相关参数
    let extraParam: Record<string, string | number> = {
      'queueMode': 0,
      'speed': 1,
      'volume': 2,
      'pitch': 1,
      'languageContext': 'zh-CN',
      'audioType': 'pcm',
      'soundChannel': 3,
      'playType': 1,
    };
    let speakParams: textToSpeech.SpeakParams = {
      requestId: Date.now().toString(),
      extraParams: extraParam,
    };
    try {
      BroadCastUtil._ttsEngine!.speak(text, speakParams);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(TAG, `Failed to speak. Code: ${err.code}, message: ${err.message}`);
    }
  }

  public static stop() {
    if (BroadCastUtil._ttsEngine) {
      BroadCastUtil._ttsEngine.stop();
    }
  }

  public static change(type: VoiceType) {
    if (BroadCastUtil._ttsEngine) {
      BroadCastUtil._ttsEngine.stop();
      BroadCastUtil._ttsEngine.shutdown();
      BroadCastUtil._ttsEngine = undefined;
    }
    BroadCastUtil._voiceModel.curVoice = type;
  }

  private static async _queryList() {
    let voicesQuery: textToSpeech.VoiceQuery = {
      requestId: Date.now().toString(),
      online: 1,
    };
    if (!BroadCastUtil._ttsEngine) {
      await BroadCastUtil._createEngine();
    }
    return BroadCastUtil._ttsEngine!.listVoices(voicesQuery).catch((err: BusinessError) => {
      Logger.error(TAG, `Failed to listVoices. Code: ${err.code}, message: ${err.message}`);
      return [];
    });
  }
}