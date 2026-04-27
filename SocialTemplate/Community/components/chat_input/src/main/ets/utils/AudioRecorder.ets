import { fileIo as fs } from '@kit.CoreFileKit';
import { audio } from '@kit.AudioKit'
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN: number = 0x0000
const TAG: string = 'AudioRecorder'

// 音频录制
export class AudioRecorder {
  private startTime: number = 0
  private endTime: number = 0
  private fileSize: number = 0
  private audioCapturer: audio.AudioCapturer | undefined = undefined;
  currentAmplitude: number = 0
  // 录音结束回调
  audioRecorderCallback: (size: number, duration: number) => void

  constructor(audioRecorderCallback: (size: number, duration: number) => void) {
    this.audioRecorderCallback = audioRecorderCallback
  }

  // 开始录制
  startRecorder(path: string) {
    let audioStreamInfo: audio.AudioStreamInfo = {
      samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_16000, // 采样率
      channels: audio.AudioChannel.CHANNEL_1, // 通道
      sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE, // 采样格式
      encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW // 编码格式
    };
    let audioCapturerInfo: audio.AudioCapturerInfo = {
      source: audio.SourceType.SOURCE_TYPE_MIC,
      capturerFlags: 0
    };
    let audioCapturerOptions: audio.AudioCapturerOptions = {
      streamInfo: audioStreamInfo,
      capturerInfo: audioCapturerInfo
    };
    try {
      audio.createAudioCapturer(audioCapturerOptions, async (err, data) => {
        if (err) {
          hilog.error(DOMAIN, TAG, '%{public}s', `Invoke createAudioCapturer failed, code is ${err.code}, message is ${err.message}`);
        } else {
          hilog.info(DOMAIN, TAG, '%{public}s', 'Invoke createAudioCapturer succeeded.示例创建成功');
          this.audioCapturer = data;
          this.onAudioWriteData(path, this.audioCapturer);

          hilog.info(DOMAIN, TAG, '%{public}s', '开启监听成功');

          this.startRecording()
        }
      });
    } catch (err) {
    }
  }

  // 获取振幅
  private getNormalizedAmplitude(buffer: ArrayBuffer): number {
    const int16Array = new Int16Array(buffer);
    let maxVal = 0;
    for (const value of int16Array) {
      maxVal = Math.max(maxVal, Math.abs(value));
    }
    const amplitude = Math.min(maxVal / 32767, 1.0); // 限制最大值为1
    this.currentAmplitude = amplitude
    hilog.info(DOMAIN, TAG, '%{public}s', 'amplitude=' + amplitude.toString());
    return amplitude
  }

  onAudioWriteData(path: string, audioCapturer: audio.AudioCapturer) {
    let file: fs.File | undefined = undefined;
    try {
      class Options {
        offset?: number;
        length?: number;
      }
      let file = fs.openSync(path, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      let bufferSize: number = 0;
      let readDataCallback = (buffer: ArrayBuffer) => {
        let options: Options = {
          offset: bufferSize,
          length: buffer.byteLength
        };
        fs.writeSync(file.fd, buffer, options);
        bufferSize += buffer.byteLength;
        this.fileSize = bufferSize
        this.getNormalizedAmplitude(buffer)
      };
      audioCapturer.on('readData', readDataCallback);

    } catch (err) {
      hilog.error(DOMAIN, TAG, '%{public}s', 'readData failed ' + err.code + err.message);
    } finally {
      audioCapturer.on('stateChange', (state: audio.AudioState) => {
        if (state === audio.AudioState.STATE_RELEASED) {
          if (file !== undefined) {
            fs.close(file);
          }
        }
      });
    }
  }

  //开始录制
  private startRecording() {
    this.startTime = Date.now()
    this.audioCapturer?.start().then(() => {
      hilog.info(DOMAIN, TAG, '%{public}s', '开始录音');
    }).catch((err: BusinessError) => {
      hilog.error(DOMAIN, TAG, '%{public}s', '录制录音' + err.code + err.message);
    });
  }

  // 停止录制
  public stopRecorder() {
    this.endTime = Date.now()
    if (this.audioCapturer) {
      this.audioCapturer.stop().then(() => {
        this.audioCapturer?.release();
        this.audioRecorderCallback(this.fileSize, this.endTime - this.startTime)
      }).catch((err: BusinessError) => {
        hilog.error(DOMAIN, TAG, '%{public}s', '录音停止失败' + err.code + err.message);
      });
    }
  }
}