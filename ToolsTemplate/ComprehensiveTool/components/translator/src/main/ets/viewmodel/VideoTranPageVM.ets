import {
  BUFFER_SIZE,
  INTERVAL_TIME,
  RecordStatus,
  STATUS_FIRST_FRAME,
  STATUS_LAST_FRAME,
  STATUS_CONTINUE_FRAME,
  allLanguages
} from '../common/Constant';
import { PersistenceV2 } from '@kit.ArkUI';
import { FileInfo } from '../model/Audio';
import { RecorderManage } from '../util/RecorderUtil';
import { PermissionUtil } from '../util/PermissionUtil';
import { PlayUtil } from '../util/PlayUtil';
import { speechRecognizer } from '@kit.CoreSpeechKit';
import { buffer, util } from '@kit.ArkTS';
import { WebAudio } from '../model/Ws';
import { ws, wsParam, WsUtil } from '../util/WSUtils';
import fs from '@ohos.file.fs'
import { copyFile, createFd, extractToPCM } from '../util/PcmUtil';
import { TranslatorService } from '../service/TranslatorService';
import { HistoryInfo, MyHistory } from '../model/History';
import { TranLogger } from '../util/TranLogger';
import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';
import { UtilLog } from '@hw-agconnect/util-log';

@ObservedV2
export class VideoTranPageVM {
  private static _instance: VideoTranPageVM
  private recorderManage: RecorderManage = new RecorderManage();
  private playUtil: PlayUtil = new PlayUtil();
  asrEngine: speechRecognizer.SpeechRecognitionEngine | null = null;
  @Trace recordStatus: RecordStatus = RecordStatus.PENDING
  @Trace curFile: FileInfo | undefined = undefined;
  // 当前播放位置
  @Trace curTime: number = 0;
  // 录音时长：单位秒
  @Trace duration: number = 1;
  // 是否正在播放
  @Trace isPlaying: boolean = false;
  // 定时器
  @Trace timer: number = 0
  // 记录时长
  @Trace recordTime: number = 0
  // 记录时长文本
  @Trace recordTimeText: string = '00:00'
  @Trace history = PersistenceV2.connect(MyHistory, () => new MyHistory())!;
  @Trace inputLanguage: string = '中文'
  @Trace outputLanguage: string = '英文'
  @Trace translatorRes: string = ''
  @Trace tempPath: string = ''
  @Trace pcmPath: string = ''
  @Trace text: string = ''
  @Trace input: string = ''

  public static get instance() {
    if (!VideoTranPageVM._instance) {
      VideoTranPageVM._instance = new VideoTranPageVM();
    }
    return VideoTranPageVM._instance;
  }

  // 记录时间
  setRecordTime() {
    this.timer = setInterval(() => {
      this.recordTime += 1
      this.recordTimeText = this.formatSecondsToMinutesSeconds(this.recordTime)
    }, 1000)
  }

  formatSecondsToMinutesSeconds(seconds: number): string {
    if (seconds < 0) {
      throw new Error('秒数不能为负数');
    }

    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = seconds % 60;

    const formattedMinutes = String(minutes).padStart(2, '0');
    const formattedSeconds = String(remainingSeconds).padStart(2, '0');

    return `${formattedMinutes}:${formattedSeconds}`;
  }

  // 清空
  public clear() {
    WsUtil.text = ''
    WsUtil.close()
    this.timer = 0
    this.recordTime = 0
    this.recordTimeText = '00:00'
    this.translatorRes = ''
    this.recordStatus = RecordStatus.PENDING
    this.inputLanguage = '中文'
    this.outputLanguage = '英文'
    this.pause()
  }

  // 重新开始录制
  public reStart() {
    // 主动关闭连接
    WsUtil.close()
    WsUtil.text = ''
    this.timer = 0
    this.recordTime = 0
    this.recordTimeText = '00:00'
    this.translatorRes = ''
    this.recordStatus = RecordStatus.PROGRESS
    this.pause()
    this.start()
  }

  // 开始录制
  public async start() {
    const res: boolean = await PermissionUtil.requestPermissions(['ohos.permission.MICROPHONE']);
    if (!res) {
      promptAction.showToast({ message: '录音功能需要先开启麦克风权限！' });
      return;
    }
    this.curFile = await this.recorderManage.startRecordingProcess();
    this.recordStatus = RecordStatus.PROGRESS;
    this.setRecordTime()
  }

  // 停止录制
  public async stop() {
    clearInterval(this.timer)
    this.curFile = await this.recorderManage.stopRecordingProcess();
    this.recordStatus = RecordStatus.OFF;
    // 转为PCM格式
    this.pcmPath = createFd('PCM').filePath;
    const filePath = copyFile(this.curFile.filePath)
    this.tempPath = filePath
    await extractToPCM(this.curFile.filePath, this.pcmPath);

    // 初始化播放器
    this.init();
    this.initPlayer();
    WsUtil.path = this.pcmPath
    this.send(this.pcmPath)
  }

  init() {
    this.duration = 1;
    this.curTime = 0;
  }

  // 初始化播放器
  public initPlayer() {
    this.playUtil.onCompleted = this.onCompleted;
    this.playUtil.onPrepared = this.onPrepared;
    this.playUtil.onTimeUpdate = this.onTimeUpDate;
    this.curTime = 0;
    this.playUtil.playerUrlInit(this.tempPath);
  }

  // 播放音频
  public play() {
    this.playUtil.play();
    this.isPlaying = true;
  }

  // 暂停
  public pause() {
    this.playUtil.pause();
    this.isPlaying = false;
  }

  // 准备完成的回调，在该周期获取音频时长
  private onPrepared = (duration: number) => {
    this.duration = duration;
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

  async send(path: string) {
    let file: fs.File | null = null;
    let fileData: ArrayBuffer | undefined;
    try {
      const filePath = path
      if (!fs.accessSync(filePath)) {
        return
      }
      const stat = fs.statSync(filePath);
      if (stat.size <= 0) {
        return
      }
      const arrayBuffer = new ArrayBuffer(stat.size)
      file = fs.openSync(filePath, fs.OpenMode.READ_WRITE)
      fs.readSync(file.fd, arrayBuffer)
      fileData = arrayBuffer
    } catch (e) {
      TranLogger.info(`get fileData fail , msg ${e} `)
    } finally {
      if (file) {
        fs.closeSync(file)
      }
    }
    if (fileData === undefined) {
      return;
    }

    const bufferSize = BUFFER_SIZE;
    let interval = INTERVAL_TIME;
    let offset = 0;
    let status = STATUS_FIRST_FRAME;
    let state = true

    while (state) {
      let nextOffset = offset + bufferSize
      let audio:string = ''
      try {
        const arrayBuffer = fileData.slice(offset, nextOffset);
        audio = buffer.from(arrayBuffer).toString('base64');
        if (!arrayBuffer || arrayBuffer.byteLength === 0) {
          status = STATUS_LAST_FRAME;
        }
        offset = nextOffset
      } catch (e) {
        UtilLog.error(`playerUrlInit failed: ${JSON.stringify(e)}`);
      }

      let d: WebAudio = {
        header: {
          status: status,
          app_id: wsParam.appId
        },
        parameter: {
          iat: wsParam.iatParams
        },
        payload: {
          audio: {
            audio: audio, sample_rate: 16000, encoding: 'raw'
          }
        }
      };

      try {
        ws.send(JSON.stringify(d));
      } catch (e) {
        JSON.stringify(e)
      }

      if (status === STATUS_LAST_FRAME) {
        state = false
        break;
      }

      status = STATUS_CONTINUE_FRAME;
      setTimeout(() => {
      }, interval * 1000);
    }
  }

  async translate() {
    const inputCode = allLanguages.find((language) => {
      return language.text === this.inputLanguage
    })
    const outputCode = allLanguages.find((language) => {
      return language.text === this.outputLanguage
    })
    this.translatorRes =
      await TranslatorService.translate(inputCode ? inputCode.code : 'cn', outputCode ? outputCode.code : 'en',
        this.text)
    if (this.translatorRes) {
      this.history.addHistory(new HistoryInfo(util.generateRandomUUID(false), this.text, this.translatorRes))
    } else {
      promptAction.showToast({ message: '暂不支持！' })
    }
  }
}
