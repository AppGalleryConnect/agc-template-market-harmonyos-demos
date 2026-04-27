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
import { audio } from '@kit.AudioKit';
import { media } from '@kit.MediaKit';
import { common } from '@kit.AbilityKit';
import { PersistenceV2 } from '@kit.ArkUI';
import { MemberManageUtil, MemberStatus, UsedCount } from 'module_base';
import { MemberSheetUtils } from 'membership';
import { yinGuitarTuning } from '../util/TuningUtil';
import { PermissionUtil, MyLog } from '../util/CommonUtil';
import { calculateCentralValue } from '../util/MathUtil';
import { GuitarInfo } from '../model/Index';
import { UtilLog } from '@hw-agconnect/util-log';

const TAG = '[TuningPageVM]';

@ObservedV2
export class TuningPageVM {
  // 当前实时获取的频率信息
  @Trace currentFreq: number = 0;
  // 展示的平均频率
  @Trace currentShowFreq: number = 0;
  // 是否存在偏差较大的频率
  @Trace hasErrorFreq: boolean = false;
  // 提示语
  @Trace tips: string = '';
  @Trace centOffset: number = 0;
  @Trace isCapturing: boolean = false;
  @Trace hasPermission: boolean = false;
  // 吉他标准音配置
  @Trace guitarStandard: GuitarInfo[] = [
    {
      note: 'D3',
      freq: 146.83,
      filePath: 'D3.mp3',
      icon: $r('app.media.d3'),
      activeIcon: $r('app.media.d3_on'),
    },
    {
      note: 'G3',
      freq: 196.00,
      filePath: 'G3.mp3',
      icon: $r('app.media.g3'),
      activeIcon: $r('app.media.g3_on'),
    },
    {
      note: 'A2',
      freq: 110.00,
      filePath: 'A2.mp3',
      icon: $r('app.media.a2'),
      activeIcon: $r('app.media.a2_on'),
    },
    {
      note: 'B3',
      freq: 246.94,
      filePath: 'B3.mp3',
      icon: $r('app.media.b3'),
      activeIcon: $r('app.media.b3_on'),
    },
    {
      note: 'E2',
      freq: 82.41,
      filePath: 'E2.mp3',
      icon: $r('app.media.e2'),
      activeIcon: $r('app.media.e2_on'),
    },
    {
      note: 'E4',
      freq: 329.63,
      filePath: 'E4.mp3',
      icon: $r('app.media.e4'),
      activeIcon: $r('app.media.e4_on'),
    },
  ];
  // 当前琴弦对应的索引
  @Trace currenNoteIndex: number = -1;
  @Trace soundMap: Map<string, number> = new Map();
  @Trace usedCount: UsedCount =
    PersistenceV2.connect(UsedCount, 'GuitarUsedCount', () => new UsedCount())!;
  @Trace isMember: boolean = false;
  // 临时保存当前一段稳定的频率
  private freqArr: number[] = [];
  // 成功的音效
  private successAudio: string = 'Success.mp3';
  private audioCapturer: audio.AudioCapturer | null = null;
  private soundPool: media.SoundPool | null = null;
  private currentStreamId: number = -1;
  private timer: number = 0;
  private static _instance: TuningPageVM;

  public static get instance() {
    if (!TuningPageVM._instance) {
      TuningPageVM._instance = new TuningPageVM();
    }
    return TuningPageVM._instance;
  }

  @Monitor('currentFreq')
  handleResult() {
    if (this.currentFreq > 0) {
      // 保存一段时间的频率数据
      this.freqArr.push(this.currentFreq);
      this.currentShowFreq = 0;
    } else {
      // 确保频率连续性
      if (this.freqArr.length > 10) {
        // 计算这段频率数据的过滤异常数据的平均值用于展示
        this.currentShowFreq = calculateCentralValue(this.freqArr);
        // 是否存在较大异常值
        this.hasErrorFreq =
          this.freqArr.some((item) => Math.abs(this.guitarStandard[this.currenNoteIndex].freq - item) > 5);
        // 处理提示语
        this.handleTips();
        // 计算音分
        this.matchGuitarNote(this.currentShowFreq);
        this.freqArr = [];
      } else {
        this.freqArr = [];
        this.currentShowFreq = 0;
      }
    }
  }

  showMemberSubscribeDialog(uiContext: UIContext) {
    let memberManageUtil = new MemberManageUtil(uiContext);
    MemberSheetUtils.open(memberManageUtil.productsInfo, uiContext);
  }

  // 获取PCM原始数据
  public async startCapture(uiContext:UIContext) {
    if (!this.hasPermission) {
      uiContext.getPromptAction().showToast({ message: '请开启麦克风权限' });
      return;
    }
    if (this.currenNoteIndex === -1) {
      return;
    }
    try {
      // 配置采集参数：单声道、16位PCM、44100Hz（适合音频分析）
      const captureConfig: audio.AudioCapturerOptions = {
        streamInfo: {
          samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_44100,
          channels: audio.AudioChannel.CHANNEL_1, // 单声道减少计算量
          sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE, // 16位整型PCM
          encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW, // 原始数据，不编码
        },
        capturerInfo: {
          source: audio.SourceType.SOURCE_TYPE_MIC, // 麦克风输入
          capturerFlags: 0,
        },
      };

      // 创建AudioCapturer实例
      this.audioCapturer = await audio.createAudioCapturer(captureConfig);
      if (this.audioCapturer) {
        // 监听采集到的PCM数据
        this.audioCapturer.on('readData', (buffer: ArrayBuffer) => {
          this.processAudio(buffer);
        });
        // 启动采集
        await this.audioCapturer.start();
        this.isCapturing = true;
      }
    } catch (error) {
      this.isCapturing = false;
    }
  }


  // 请求麦克风权限
  public async handlePermission(ctx:Context) {
    this.hasPermission = await PermissionUtil._checkPermissions('ohos.permission.MICROPHONE');
    if (!this.hasPermission) {
      await PermissionUtil.requestPermissions(['ohos.permission.MICROPHONE'],ctx);
      this.hasPermission = await PermissionUtil._checkPermissions('ohos.permission.MICROPHONE');
    }
  }

  // 停止采集并释放资源
  public async stopCapture() {
    if (this.audioCapturer) {
      try {
        await this.audioCapturer.stop();
        this.audioCapturer.release(); // 释放AudioCapturer资源
      } catch (error) {
        MyLog.error('停止采集失败：', error);
      } finally {
        this.audioCapturer = null;
      }
    }
    this.isCapturing = false;
    this.currentFreq = 0;
    this.centOffset = 0;
  }

  // 初始化 SoundPool
  async initSoundPool(uiContext: UIContext) {
    try {
      this.soundPool = await media.createSoundPool(5, {
        usage: audio.StreamUsage.STREAM_USAGE_MUSIC,
        rendererFlags: 0,
      });
      if (this.soundPool) {
        this.soundPool.on('loadComplete', (soundId) => {
          MyLog.info('加载完成' + soundId);
        });
        this.soundPool.on('error', (err) => {
          MyLog.error('错误', err.message);
        });

        this.soundPool.on('playFinished', () => {
          this.currentStreamId = -1;
        });

        for (let i = 0; i < this.guitarStandard.length; i++) {
          this.loadAudio(this.guitarStandard[i].filePath, uiContext).then((res) => {
            this.soundMap.set(this.guitarStandard[i].filePath, res);
          });
        }
        this.loadAudio(this.successAudio, uiContext).then((res) => {
          this.soundMap.set(this.successAudio, res);
        });
      }
    } catch (e) {
      UtilLog.error(`session close failed: ${JSON.stringify(e)}`);
    }
  }

  // 加载新音频源
  async loadAudio(filePath: string, uiContext: UIContext) {
    if (this.soundPool) {
      // 加载新资源
      const fileDescriptor = await uiContext.getHostContext()!.resourceManager.getRawFd(filePath);
      const soundId = await this.soundPool.load(fileDescriptor.fd, fileDescriptor.offset, fileDescriptor.length);
      return soundId;
    }
    return -1;
  }

  // 播放控制
  async playAudio(soundId: number = -1, isSingle: boolean = true) {
    if (this.currentStreamId !== -1 && isSingle) {
      return;
    }
    const playParams: media.PlayParameters = {
      loop: 0,
      rate: audio.AudioRendererRate.RENDER_RATE_NORMAL,
      leftVolume: 1.0,
      rightVolume: 1.0,
      priority: 1,
    };
    if (this.soundPool) {
      try {
        this.currentStreamId = await this.soundPool.play(soundId, playParams);
      } catch (e) {
        MyLog.error('播放失败', JSON.stringify(e));
      }
    }
  }

  // 释放资源
  async releasePool() {
    if (!this.soundPool) {
      return;
    }
    try {
      // 停止播放
      if (this.currentStreamId !== -1) {
        await this.soundPool.stop(this.currentStreamId);
      }
      // 卸载所有音频
      for (const soundId of this.soundMap.values()) {
        await this.soundPool.unload(soundId);
      }
      this.soundMap.clear();
      // 移除事件监听
      this.soundPool.off('loadComplete');
      this.soundPool.off('error');
      this.soundPool.off('playFinished');
      //  重置id
      this.currentStreamId = -1;
      // 释放SoundPool实例
      await this.soundPool.release();

    } catch (error) {
      MyLog.error(`释放SoundPool资源时发生错误: ${error.message}`);
    }
  }


  // 处理PCM数据（频率提取→标准音对比）
  private processAudio(pcmBuffer: ArrayBuffer) {
    // 将16位PCM（ArrayBuffer）转为Float32Array
    const pcmInt16 = new Int16Array(pcmBuffer);
    // YIN算法提取音频
    const res = yinGuitarTuning(pcmInt16);
    this.currentFreq = res;
  }

  // 对比吉他标准音，计算音分偏差
  private async matchGuitarNote(inputFreq: number) {
    let target = this.guitarStandard[this.currenNoteIndex];
    // 音分计算公式：1200 × log2(输入频率 / 标准频率)（1音分=1/100半音）
    this.centOffset = 1200 * Math.log2(inputFreq / target.freq);
    if (Math.abs(this.centOffset) < 5 && !this.hasErrorFreq) {
      this.tips = `${this.currentShowFreq}Hz,已调准`;
      this.playAudio(this.soundMap.get(this.successAudio), false);
      // 调准后暂停1.5s，优化用户感知
      if (this.audioCapturer && this.isCapturing) {
        try {
          await this.audioCapturer.stop();
          this.isCapturing = false;
        } catch (e) {
          MyLog.error('停止失败');
          this.isCapturing = true;
        }
      }
      this.timer = setTimeout(async () => {
        if (this.audioCapturer && !this.isCapturing) {
          try {
            await this.audioCapturer.start();
            this.isCapturing = true;
          } catch (e) {
            MyLog.error('启动失败');
            this.isCapturing = false;
          }
        }
        clearTimeout(this.timer);
      }, 1500);
    }
  }


  private handleTips() {
    if (this.centOffset > 5) {
      this.tips = `${this.currentShowFreq}Hz,音偏高请拧松${this.guitarStandard[this.currenNoteIndex].note}弦`;
    } else if (this.centOffset < -5) {
      this.tips = `${this.currentShowFreq}Hz,音偏低请拧禁${this.guitarStandard[this.currenNoteIndex].note}弦`;
    } else {
      this.tips = `${this.currentShowFreq}Hz`;
    }
  }
}