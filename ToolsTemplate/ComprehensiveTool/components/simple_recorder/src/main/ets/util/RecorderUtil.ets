import { UtilLog } from '@hw-agconnect/util-log';
import { AppStorageV2 } from '@kit.ArkUI';
import { media } from '@kit.MediaKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { FormatUtil } from '../util/FormatUtil';
import { Logger } from '../util/Logger';
import { FileInfo, MyAmplitude } from '../model/Index';
import { AMPLITUDE_MAX_HEIGHT, AMPLITUDE_MAX } from '../constant/Index';

export class RecorderUtil {
  public intervalId: number | undefined = undefined;
  private avRecorder: media.AVRecorder | undefined = undefined;
  private avProfile: media.AVRecorderProfile = {
    audioBitrate: 112000, // 音频比特率。
    audioChannels: 2, // 音频声道数。
    audioCodec: media.CodecMimeType.AUDIO_MP3, // 音频编码格式，当前支持AAC，MP3，G711MU。
    audioSampleRate: 48000, // 音频采样率。
    fileFormat: media.ContainerFormatType.CFT_MP3, // 封装格式，当前支持MP4，M4A，MP3，WAV，AMR，AAC。
  };
  private avConfig: media.AVRecorderConfig = {
    audioSourceType: media.AudioSourceType.AUDIO_SOURCE_TYPE_DEFAULT, // 音频输入源，这里设置为麦克风
    profile: this.avProfile,
    url: 'fd://35', // 参考应用文件访问与管理开发示例新建并读写一个文件
  };
  private filePath: string = '';
  private fileFd: number = 0;
  private fileName: string = '';
  private static _instance: RecorderUtil;

  public static get instance() {
    if (!RecorderUtil._instance) {
      RecorderUtil._instance = new RecorderUtil();
    }
    return RecorderUtil._instance;
  }

  // 创建文件以及设置avConfig.url
  async createAndSetFd(): Promise<void> {
    const context: Context = AppStorage.get('simple_recorder_context') as Context;
    const fileName: string = `${FormatUtil.formatFullDate(new Date())}_录音.mp3`;
    const path: string = context.filesDir + `/${fileName}`; // 文件沙箱路径，文件后缀名应与封装格式对应
    const audioFile: fs.File = fs.openSync(path, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
    this.avConfig.url = 'fd://' + audioFile.fd; // 更新url
    // 保存沙箱路径和文件名
    this.filePath = path;
    this.fileName = fileName;
    this.fileFd = audioFile.fd;
  }

  // 注册audioRecorder回调函数
  setAudioRecorderCallback() {
    if (this.avRecorder !== undefined) {
      // 状态机变化回调函数
      this.avRecorder.on('stateChange', (state: media.AVRecorderState, reason: media.StateChangeReason) => {
        Logger.info(`AudioRecorder current state is ${state}`);
      });
      // 错误上报回调函数
      this.avRecorder.on('error', (err: BusinessError) => {
        Logger.error(`AudioRecorder failed, code is ${err.code}, message is ${err.message}`);
      });
    }
  }

  // 开始录制对应的流程
  async startRecordingProcess(uiContext:UIContext) {
    if (this.avRecorder !== undefined) {
      await this.avRecorder.release();
      this.avRecorder = undefined;
    }
    // 1.创建录制实例
    try {
      this.avRecorder = await media.createAVRecorder();
    } catch (e) {
      UtilLog.error(`startRecordingProcess failed: ${JSON.stringify(e)}`);
    }

    this.setAudioRecorderCallback();
    // 2.获取录制文件fd赋予avConfig里的url；参考FilePicker文档
    await this.createAndSetFd();
    // 3.配置录制参数完成准备工作
    await this.avRecorder?.prepare(this.avConfig);
    // 4.开始录制
    await this.avRecorder?.start();
    // 绘制频谱图
    this.draw(uiContext);
    const fileInfo: FileInfo = {
      filePath: this.filePath,
      fileName: this.fileName,
    };
    return fileInfo;
  }

  // 暂停录制对应的流程
  async pauseRecordingProcess() {
    if (this.avRecorder !== undefined && this.avRecorder.state === 'started') { // 仅在started状态下调用pause为合理状态切换
      await this.avRecorder.pause();
    }
  }

  // 恢复录制对应的流程
  async resumeRecordingProcess() {
    if (this.avRecorder !== undefined && this.avRecorder.state === 'paused') { // 仅在paused状态下调用resume为合理状态切换
      await this.avRecorder.resume();
    }
  }

  // 停止录制对应的流程
  async stopRecordingProcess() {
    if (this.avRecorder !== undefined) {
      // 1. 停止录制
      // 仅在started或者paused状态下调用stop为合理状态切换
      if (this.avRecorder.state === 'started' ||
        this.avRecorder.state === 'paused') {
        await this.avRecorder.stop();
      }
      // 2.重置
      await this.avRecorder.reset();
      // 3.释放录制实例
      await this.avRecorder.release();
      this.avRecorder = undefined;
      // 4.关闭录制文件fd
      await fs.close(this.fileFd);
    }
    if (this.intervalId) {
      clearInterval(this.intervalId);
    }
    const fileInfo: FileInfo = {
      filePath: this.filePath,
      fileName: this.fileName,
    };
    return fileInfo;
  }


  draw(uiContext:UIContext) {
    // 录制音频时，设置定时器
    this.intervalId = setInterval(() => {
      this.avRecorder?.getAudioCapturerMaxAmplitude()
        .then((amplitude) => {
          uiContext.animateTo({
            curve: Curve.EaseInOut,
            duration: 200,
          }, () => {
            if (amplitude) {
              const myAmplitude = AppStorageV2.connect(MyAmplitude, () => new MyAmplitude(data))!;
              const data = amplitude / AMPLITUDE_MAX * AMPLITUDE_MAX_HEIGHT;
              myAmplitude.amplitude = data;
            }
          });
        })
        .catch((err: BusinessError) => {
          Logger.error(`Failed to getAudioCapturerMaxAmplitude. Code is ${err.code}, message is ${err.message}`);
        });
    }, 200);
  }
}