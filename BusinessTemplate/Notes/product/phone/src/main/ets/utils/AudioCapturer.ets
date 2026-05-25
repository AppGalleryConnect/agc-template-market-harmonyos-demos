import { audio } from '@kit.AudioKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { fileIo } from '@kit.CoreFileKit';
import { Constants } from './VoiceAudioConstants';
import { common } from '@kit.AbilityKit';

const DOMAIN = 0x0000;
const TAG = 'AudioCapturer';

interface GeneratedObjectLiteralInterface_1 {
  samplingRate: audio.AudioSamplingRate;
  channels: audio.AudioChannel;
  sampleFormat: audio.AudioSampleFormat;
  encodingType: audio.AudioEncodingType;
}

interface GeneratedObjectLiteralInterface_2 {
  source: audio.SourceType;
  capturerFlags: number;
}

interface GeneratedObjectLiteralInterface_3 {
  streamInfo: GeneratedObjectLiteralInterface_1;
  capturerInfo: GeneratedObjectLiteralInterface_2;
}

export class AudioCapturer {
  private sampleValCnt: number = 0;
  private sampleValSum: number = 0;
  private savedDbs: number[] = [];
  private audioCapturer: audio.AudioCapturer | undefined = undefined;
  private dataCallBack: ((data: ArrayBuffer) => void) | null = null;
  private fd?: number = 0;
  private url: string = '';

  getSavedDbData(): number[] {
    return this.savedDbs;
  }

  calculateDecibelHeight(): number {
    if (this.sampleValCnt === 0) {
      return 0;
    }
    let rms = this.sampleValSum / this.sampleValCnt;
    let db = Math.max(Constants.MIN_DB, Math.min(0, 20 * Math.log10(rms)));
    this.sampleValCnt = 0;
    this.sampleValSum = 0;
    let res = Math.max(2, (db + Math.abs(Constants.MIN_DB)) / Math.abs(Constants.MIN_DB) * Constants.WAVE_HEIGHT_RADIO);
    this.savedDbs.push(res);
    return res;
  }

  private audioStreamInfo: GeneratedObjectLiteralInterface_1 = {
    samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_16000,
    channels: audio.AudioChannel.CHANNEL_1,
    sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
    encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW,
  };

  private audioCapturerInfo: GeneratedObjectLiteralInterface_2 = {
    source: audio.SourceType.SOURCE_TYPE_MIC,
    capturerFlags: 0,
  };

  private audioCapturerOptions: GeneratedObjectLiteralInterface_3 = {
    streamInfo: this.audioStreamInfo,
    capturerInfo: this.audioCapturerInfo,
  };

  /**
   * 创建录音实例并开始录音，文件保存为 cacheDir/filename.pcm
   */
  createOn(filename: string, context: common.UIAbilityContext) {
    audio.createAudioCapturer(this.audioCapturerOptions, async (err, data) => {
      if (err) {
        hilog.error(DOMAIN, TAG, `Invoke createAudioCapturer failed, code is ${err.code}, message is ${err.message}`);
      } else {
        hilog.info(DOMAIN, TAG, 'Invoke createAudioCapturer succeeded.');
        this.audioCapturer = data;
        this.savedDbs = [];
        let bufferSize: number = 0;

        class Options {
          offset?: number;
          length?: number;
        }

        let path = context.cacheDir;
        let filePath = path + `/${filename}.pcm`;
        let file: fileIo.File = await fileIo.open(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
        this.fd = file.fd;
        this.url = 'fd://' + file.fd;
        let readDataCallback = async (buffer: ArrayBuffer) => {
          let options: Options = {
            offset: bufferSize,
            length: buffer.byteLength,
          };
          await fileIo.write(file.fd, buffer, options);
          bufferSize += buffer.byteLength;
          AppStorage.setOrCreate('RecordOffset', bufferSize);

          let samples = new Int16Array(buffer);
          for (let i = 0; i < samples.length; i++) {
            let val = samples[i] / Constants.VOLUME_MAX;
            this.sampleValSum += val * val;
            this.sampleValCnt += 1;
          }
        };
        this.dataCallBack = readDataCallback;

        this.audioCapturer.on('readData', readDataCallback);
        this.audioCapturer.on('stateChange', (state: audio.AudioState) => {
          if (state === audio.AudioState.STATE_RELEASED) {
            fileIo.close(file);
          }
        });
        hilog.info(DOMAIN, TAG, 'start listening');
        this.startRecording();
      }
    });
  }

  setDataCallback(dataCallBack: (data: ArrayBuffer) => void) {
    this.dataCallBack = dataCallBack;
  }

  startRecording() {
    if (!this.audioCapturer) {
      hilog.warn(DOMAIN, TAG, 'AudioCapturer not initialized yet.');
      return;
    }
    this.audioCapturer.start().then(() => {
      hilog.info(DOMAIN, TAG, 'start record');
    }).catch((err: BusinessError) => {
      hilog.error(DOMAIN, TAG, 'start record failed ' + err.code + err.message);
    });
  }

  async stopAndRelease() {
    if (this.audioCapturer) {
      try {
        await this.audioCapturer.stop();
        await this.audioCapturer.release();
        if (this.fd !== undefined) {
          await fileIo.close(this.fd);
          this.fd = undefined;
        }
      } catch (err) {
        hilog.error(DOMAIN, TAG, 'stop record failed ' + err.code + err.message);
      }
    }
  }
}

