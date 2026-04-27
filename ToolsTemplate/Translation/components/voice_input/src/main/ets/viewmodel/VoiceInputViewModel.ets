/**
 * 语音输入ViewModel
 * 权限说明：使用 ohos.permission.MICROPHONE 权限
 * - 已在 module.json5 中声明
 * - 运行时通过 requestPermissionsFromUser 动态请求
 *
 * 实现说明：
 * - 支持实时语音识别（enableAudioRecord=true）
 * - 区分中间结果和最终结果
 * - 提供完整的生命周期管理
 */
import { VoiceInputStatus, VoiceRecognitionResult } from '../model/VoiceInputModel';
import { speechRecognizer } from '@kit.CoreSpeechKit';
import { abilityAccessCtrl, common } from '@kit.AbilityKit';
import { util } from '@kit.ArkTS';
import { audio } from '@kit.AudioKit';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';

const TAG = '[VoiceInputViewModel]';

@ObservedV2
export class VoiceInputViewModel {
  @Trace status: VoiceInputStatus = VoiceInputStatus.IDLE;
  @Trace volumeList: number[] = [10, 20, 30, 40, 30, 20, 10];
  @Trace resultText: string = ''; // 用于UI显示的完整文本

  // 语音识别结果（区分中间结果和最终结果）
  @Trace recognitionResult: VoiceRecognitionResult = new VoiceRecognitionResult();
  private timer: number = -1;
  private asrEngine: speechRecognizer.SpeechRecognitionEngine | null = null;
  private sessionId: string = '';
  private isEngineInitialized: boolean = false;
  private audioCapturer: audio.AudioCapturer | null = null;
  private isCapturing: boolean = false;

  /**
   * 开始语音识别
   */
  async startListening(context: common.UIAbilityContext) {

    // 检查权限
    const hasPermission = await this.requestPermission(context);
    if (!hasPermission) {
      return;
    }

    // 更新状态
    this.status = VoiceInputStatus.LISTENING;
    this.resultText = '';
    this.recognitionResult = new VoiceRecognitionResult();
    this.startWaveAnimation();

    try {
      // 初始化并启动ASR引擎
      await this.initAsrEngine();
      await this.startAsrSession();
    } catch (error) {
      this.handleError();
    }
  }

  /**
   * 停止语音识别
   */
  async stopListening() {
    this.stopWaveAnimation();

    // 先停止音频采集
    await this.stopAudioCapture();

    // 停止ASR会话
    if (this.asrEngine && this.sessionId) {
      try {
        this.asrEngine.finish(this.sessionId);
      } catch (error) {
      }
    }

    this.status = VoiceInputStatus.IDLE;
  }

  /**
   * 取消语音识别
   */
  async cancelListening() {
    this.stopWaveAnimation();

    // 先停止音频采集
    await this.stopAudioCapture();

    // 取消ASR会话
    if (this.asrEngine && this.sessionId) {
      try {
        this.asrEngine.cancel(this.sessionId);
      } catch (error) {
      }
    }

    this.status = VoiceInputStatus.IDLE;
    this.resultText = '';
    this.recognitionResult = new VoiceRecognitionResult();
  }

  /**
   * 清除识别结果
   */
  clearResult(): void {
    this.resultText = '';
    this.recognitionResult = new VoiceRecognitionResult();
    this.status = VoiceInputStatus.IDLE;
  }

  /**
   * 释放ASR引擎资源
   */
  async shutdown() {
    if (this.asrEngine) {
      try {
        this.asrEngine.shutdown();
        this.asrEngine = null;
        this.isEngineInitialized = false;
        this.sessionId = '';
      } catch (error) {
      }
    }
  }

  /**
   * 请求麦克风权限
   */
  private async requestPermission(context: common.UIAbilityContext): Promise<boolean> {
    const manager = abilityAccessCtrl.createAtManager();
    try {
      // 先检查当前权限状态
      const tokenId = context.applicationInfo.accessTokenId;
      const permissionStatus = manager.checkAccessTokenSync(tokenId, 'ohos.permission.MICROPHONE');

      // 如果已经授权，直接返回
      if (permissionStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        return true;
      }

      // 请求权限
      const result = await manager.requestPermissionsFromUser(context, ['ohos.permission.MICROPHONE']);
      const granted = result.authResults[0] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;

      if (!granted) {
        // 权限被拒绝，检查是否可以再次请求
        const dialogResult = result.dialogShownResults;
        if (dialogResult && dialogResult[0] === false) {
          // 用户之前拒绝过且选择了"不再询问"，需要引导去设置页面
          this.openPermissionSettings(context);
        }
      }

      return granted;
    } catch (error) {
      return false;
    }
  }

  /**
   * 打开应用权限设置页面
   */
  private openPermissionSettings(context: common.UIAbilityContext): void {
    try {
      const bundleInfo = context.applicationInfo;
      context.startAbility({
        bundleName: 'com.huawei.hmos.settings',
        abilityName: 'com.huawei.hmos.settings.MainAbility',
        uri: 'application_info_entry',
        parameters: {
          pushParams: bundleInfo.name
        }
      });
    } catch (error) {
    }
  }

  /**
   * 初始化ASR引擎（仅创建引擎实例和设置监听器）
   */
  private async initAsrEngine() {
    try {
      if (this.isEngineInitialized) {
        return;
      }

      const createParams: speechRecognizer.CreateEngineParams = {
        language: 'zh-CN',
        online: 1,
        extraParams: {
          locate: 'CN',
          recognizerMode: 'short'  // 短语音模式，适合语音输入
        }
      };

      this.asrEngine = await speechRecognizer.createEngine(createParams);
      this.setAsrListener();
      this.isEngineInitialized = true;
    } catch (err) {
    }
  }

  /**
   * 启动ASR识别会话
   */
  private async startAsrSession() {
    if (!this.asrEngine) {
      throw new Error('ASR engine not initialized');
    }

    this.sessionId = util.generateRandomUUID(false);
    const startParams: speechRecognizer.StartParams = {
      sessionId: this.sessionId,
      audioInfo: {
        audioType: 'pcm',
        sampleRate: 16000,
        soundChannel: 1,
        sampleBit: 16
      },
      extraParams: {
        vadBegin: 2000, // 2秒内检测语音开始
        vadEnd: 800, // 0.8秒静音后结束
        maxAudioDuration: 60000,
        enablePartialResult: true
      }
    };

    this.asrEngine.startListening(startParams);

    // 启动音频录制并推送
    await this.startAudioCapture();
  }

  /**
   * 启动音频采集
   */
  private async startAudioCapture() {
    try {
      const audioStreamInfo: audio.AudioStreamInfo = {
        samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_16000,
        channels: audio.AudioChannel.CHANNEL_1,
        sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
        encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW
      };

      const audioCapturerInfo: audio.AudioCapturerInfo = {
        source: audio.SourceType.SOURCE_TYPE_MIC,
        capturerFlags: 0
      };

      const audioCapturerOptions: audio.AudioCapturerOptions = {
        streamInfo: audioStreamInfo,
        capturerInfo: audioCapturerInfo
      };

      this.audioCapturer = await audio.createAudioCapturer(audioCapturerOptions);

      await this.audioCapturer.start();
      this.isCapturing = true;

      // 开始读取音频数据并推送到ASR
      this.readAndPushAudioData();
    } catch (error) {
      throw new Error('Failed to start audio capture: ' + JSON.stringify(error));
    }
  }

  /**
   * 读取音频数据并推送到ASR
   */
  private async readAndPushAudioData() {
    const bufferSize = 1280; // 增大缓冲区，减少读取次数

    while (this.isCapturing && this.audioCapturer) {
      try {
        // 注意：read方法已deprecated，但readData在当前SDK版本不可用
        const buffer = await this.audioCapturer.read(bufferSize, true);
        if (buffer && buffer.byteLength > 0) {
          // 推送音频数据到ASR引擎
          const uint8Array = new Uint8Array(buffer);
          this.asrEngine?.writeAudio(this.sessionId, uint8Array);
        }
      } catch (error) {
        if (this.isCapturing) {
        }
        break;
      }
    }
  }

  /**
   * 停止音频采集
   */
  private async stopAudioCapture() {
    this.isCapturing = false;

    if (this.audioCapturer) {
      try {
        await this.audioCapturer.stop();
        await this.audioCapturer.release();
        this.audioCapturer = null;
      } catch (error) {
      }
    }
  }

  /**
   * 设置ASR监听器
   */
  private setAsrListener() {
    if (!this.asrEngine) {
      return;
    }

    const listener: speechRecognizer.RecognitionListener = {
      onStart: (_sessionId: string, _eventMessage: string) => {
        this.recognitionResult.generatedText = '';
        this.recognitionResult.progressText = '';
        this.recognitionResult.isFinal = false;
      },

      onEvent: (_sessionId: string, _eventCode: number, _eventMessage: string) => {
      },

      onResult: (_sessionId: string, result: speechRecognizer.SpeechRecognitionResult) => {
        // 检查结果是否为空
        if (!result.result || result.result.trim().length === 0) {
          return;
        }

        if (result.isFinal) {
          // 最终结果：追加到已确认文本
          this.recognitionResult.generatedText += result.result;
          this.recognitionResult.progressText = '';
          this.recognitionResult.isFinal = true;
        } else {
          // 中间结果：更新临时文本
          this.recognitionResult.progressText = result.result;
          this.recognitionResult.isFinal = false;
        }

        // 更新UI显示文本（最终结果 + 中间结果）
        this.resultText = this.recognitionResult.generatedText + this.recognitionResult.progressText;
      },

      onComplete: (_sessionId: string, _eventMessage: string) => {
        // 如果有中间结果但没有最终结果，将中间结果作为最终结果
        if (this.recognitionResult.progressText && !this.recognitionResult.generatedText) {
          this.recognitionResult.generatedText = this.recognitionResult.progressText;
          this.recognitionResult.progressText = '';
          this.resultText = this.recognitionResult.generatedText;
        }

        // 只有在没有识别结果时才重置为IDLE，否则保持当前状态让用户选择操作
        if (!this.resultText || this.resultText.trim().length === 0) {
          this.status = VoiceInputStatus.IDLE;
        } else {
          // 有识别结果时，设置为完成状态（可以复用IDLE状态，因为UI会根据resultText来判断显示哪些按钮）
          this.status = VoiceInputStatus.IDLE;
        }
        this.stopWaveAnimation();
      },

      onError: (_sessionId: string, _errorCode: number, _errorMessage: string) => {
        this.handleError();
      }
    };

    this.asrEngine.setListener(listener);
  }

  /**
   * 处理错误
   */
  private async handleError() {
    this.status = VoiceInputStatus.IDLE;
    this.stopWaveAnimation();

    // 停止音频采集
    await this.stopAudioCapture();

    if (this.asrEngine && this.sessionId) {
      try {
        this.asrEngine.cancel(this.sessionId);
      } catch (e) {
      }
    }
  }

  /**
   * 生成安全随机浮点数（0到max之间）
   * 使用cryptoFramework生成密码学安全的随机数
   */
  private getSecureRandomFloat(max: number): number {
    const rand = cryptoFramework.createRandom();
    const randData = rand.generateRandomSync(1);
    return randData.data[0] * max / 255;
  }

  private startWaveAnimation() {
    if (this.timer !== -1) {
      clearInterval(this.timer);
    }
    this.timer = setInterval(() => {
      // 随机生成波纹高度模拟音量变化
      // 实际项目中可以使用音频振幅来驱动
      let newVolumes: number[] = [];
      for (let i = 0; i < 7; i++) {
        const randomValue = this.getSecureRandomFloat(40) + 10;
        newVolumes.push(randomValue);
      }
      this.volumeList = newVolumes;
    }, 200);
  }

  private stopWaveAnimation() {
    if (this.timer !== -1) {
      clearInterval(this.timer);
      this.timer = -1;
    }
    this.volumeList = [10, 10, 10, 10, 10, 10, 10];
  }
}
