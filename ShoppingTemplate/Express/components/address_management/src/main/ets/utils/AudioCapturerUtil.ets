import { audio } from '@kit.AudioKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { fileIo } from '@kit.CoreFileKit';


const TAG = '[AudioCapturerUtil]';

export class AudioCapturerUtil {
  audioCapturer: audio.AudioCapturer | undefined = undefined;
  url: string = '';

  //创建实例并开启监听
  createAudio(filename: string, context: Context) {
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
    audio.createAudioCapturer(audioCapturerOptions, (err, data) => {
      if (err) {
        UtilLog.error(TAG, `Invoke createAudioCapturer failed, code is ${err.code}, message is ${err.message}`);
      } else {
        UtilLog.info(TAG, 'Invoke createAudioCapturer succeeded.');
        this.audioCapturer = data;
        let bufferSize: number = 0;

        class Options {
          offset?: number;
          length?: number;
        }

        let path = context.cacheDir;
        let filePath = path + `/${filename}.pcm`;
        let file = fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
        this.url = 'fd://' + file.fd;
        let readDataCallback = (buffer: ArrayBuffer) => {
          let options: Options = {
            offset: bufferSize,
            length: buffer.byteLength
          };
          fileIo.writeSync(file.fd, buffer, options);
          bufferSize += buffer.byteLength;
        };
        this.audioCapturer.on('readData', readDataCallback);
        this.audioCapturer.on('stateChange', (state: audio.AudioState) => {
          if (state === 4) {
            fileIo.close(file);
          }
        });
        UtilLog.info(TAG, '开启监听成功');
        this.startRecording();
      }
    });
  }

  //开始录制
  startRecording() {
    this.audioCapturer?.start().then(() => {
      UtilLog.info(TAG, '开始录音');
    }).catch((err: BusinessError) => {
      UtilLog.error(TAG, '录制录音' + err.code + err.message);
    });
  }

  //停止录制并销毁实例
  async stopAndRelease() {
    try {
      await this.audioCapturer?.stop();
      await this.audioCapturer?.release();
    } catch (err) {
      UtilLog.error(TAG, `stopAndRelease failed. error: ${JSON.stringify(err)}`);
    }
  }
}