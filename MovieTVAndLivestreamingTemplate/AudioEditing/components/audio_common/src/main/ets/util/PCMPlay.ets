import { audio } from '@kit.AudioKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = 'PCMPLAYER'

class Options {
  offset?: number;
  length?: number;
}

export interface PlayCallBack {
  onDurationCallBack: (bufferLength: number) => void
  stopCallBack: () => void
}

@ObservedV2
export class PCMPlayer {
  pcmPath: string = '' //pcm文件路径
  audioRenderer: audio.AudioRenderer | undefined = undefined;
  samplingRate: number = 0 //采样率
  channels: number = 0 //声道数
  sampleFormat: number = audio.AudioSampleFormat.SAMPLE_FORMAT_F32LE // 采样格式。
  usage: number = audio.StreamUsage.STREAM_USAGE_MUSIC // 音频流使用类型：音乐。
  rendererFlags: number = 0 //音乐渲染标识
  writeDataCallback: (buffer: ArrayBuffer) => number = (buffer: ArrayBuffer) => 0
  file: fs.File | undefined = undefined
  callBack: PlayCallBack | undefined = undefined
  bufferSize: number = 0 //音频已播放长度
  startSize: number = 0 //音频开始播放的位置(解决音频从哪开始播放的问题)
  maxSize: number = 0 //音频最大播放长度，默认播放音频全部长度（解决播放到哪）
  audioEndStop: boolean = true //播放完成后是否结束播放（调用this.stop）
  constructor(pcmPath: string, samplingRate: number, channels: number, sampleFormat: number,
    usage = audio.StreamUsage.STREAM_USAGE_MUSIC, audioEndStop = true) {
    this.pcmPath = pcmPath
    this.samplingRate = samplingRate
    this.channels = channels
    this.sampleFormat = sampleFormat
    this.usage = usage
    this.audioEndStop = audioEndStop
  }

  setStartSize(startSize: number) {
    this.startSize = startSize
  }

  setMaxSize(maxSize: number) {
    this.maxSize = maxSize
  }

  initCallBack(callBack: PlayCallBack) {
    this.callBack = callBack
  }

  getAudioRenderOptions() {
    let audioStreamInfo: audio.AudioStreamInfo = {
      samplingRate: this.samplingRate, // 采样率。
      channels: this.channels, // 通道。
      sampleFormat: this.sampleFormat, // 采样格式。
      encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW // 编码格式。
    };
    let audioRendererInfo: audio.AudioRendererInfo = {
      usage: this.usage, // 音频流使用类型：音乐。根据业务场景配置，参考StreamUsage。
      rendererFlags: 0 // 音频渲染器标志。
    };
    let audioRendererOptions: audio.AudioRendererOptions = {
      streamInfo: audioStreamInfo,
      rendererInfo: audioRendererInfo
    };
    return audioRendererOptions
  }

  initArguments() {
    // 此处仅作示例，实际使用时需要将文件替换为应用要播放的PCM文件。
    try {
      this.file = fs.openSync(this.pcmPath, fs.OpenMode.READ_ONLY);
      this.writeDataCallback = (buffer: ArrayBuffer) => {
        let readBuffer = buffer
        //读取剩余可读取的长度
        if (this.maxSize > 0 && (this.maxSize - this.bufferSize) < buffer.byteLength) {
          const tempSize = this.maxSize - this.bufferSize < 0 ? 0 : this.maxSize - this.bufferSize
          if (tempSize === 0) {
            this.stop()
            return audio.AudioDataCallbackResult.INVALID;

          }
          readBuffer = new ArrayBuffer(tempSize)
        }
        let options: Options = {
          offset: this.bufferSize,
          length: readBuffer.byteLength
        };

        try {
          let bufferLength = fs.readSync(this.file?.fd, readBuffer, options);
          this.bufferSize += readBuffer.byteLength;
          if (bufferLength === 0) {
            this.stop()
            return audio.AudioDataCallbackResult.INVALID;

          }
          this.callBack?.onDurationCallBack(this.bufferSize)

          if (this.startSize > this.bufferSize) { //未到开始播放的位置,用静音数据填充
            bufferLength = 0
          }
          // 如果当前回调传入的数据不足一帧，空白区域需要使用静音数据填充，否则会导致播放出现杂音。
          if (bufferLength < readBuffer.byteLength) {
            this.fillInSilence(bufferLength, readBuffer)
          }

          // API version 11不支持返回回调结果，从API version 12开始支持返回回调结果。
          // 如果开发者不希望播放某段buffer，返回audio.AudioDataCallbackResult.INVALID即可。
          return audio.AudioDataCallbackResult.VALID;
        } catch (error) {
          // API version 11不支持返回回调结果，从API version 12开始支持返回回调结果。
          return audio.AudioDataCallbackResult.INVALID;
        }
      };

    } catch (err) {
      fs.closeSync(this.file)
      this.file = undefined
    } finally {

    }
  }

  //填充静音
  fillInSilence(bufferLength: number, readBuffer: ArrayBuffer) {
    let view = new DataView(readBuffer);
    for (let i = bufferLength; i < readBuffer.byteLength; i++) {
      // 空白区域填充静音数据。当使用音频采样格式为SAMPLE_FORMAT_U8时0x7F为静音数据，使用其他采样格式时0为静音数据。
      if (this.sampleFormat === audio.AudioSampleFormat.SAMPLE_FORMAT_U8) {
        view.setUint8(i, 0x7F)
      } else {
        view.setUint8(i, 0)
      }
    }
  }

  init() {
    this.initArguments()
    let audioRendererOptions = this.getAudioRenderOptions()
    try {
      audio.createAudioRenderer(audioRendererOptions, (err, renderer) => { // 创建AudioRenderer实例。
        if (!err) {
          this.audioRenderer = renderer;
          if (this.audioRenderer !== undefined) {
            this.audioRenderer.on('writeData', this.writeDataCallback);
          }
        }
      });
    } catch (err) {
    }
  }
  resetBufferSize(){
    this.bufferSize = 0
  }

  skipPlay(skipSize: number, totalSize: number) {
    this.bufferSize += skipSize
    if (this.bufferSize < 0) {
      this.bufferSize = 0
    }
    if (this.bufferSize > totalSize) {
      this.bufferSize = totalSize
    }
  }

  // 开始一次音频渲染
  start() {
    if (this.audioRenderer !== undefined) {
      let stateGroup = [audio.AudioState.STATE_PREPARED, audio.AudioState.STATE_PAUSED, audio.AudioState.STATE_STOPPED];
      if (stateGroup.indexOf(this.audioRenderer.state.valueOf()) === -1) { // 当且仅当状态为prepared、paused和stopped之一时才能启动渲染。
        return;
      }
      // 启动渲染。
      this.audioRenderer.start((err: BusinessError) => {
      });
    }
  }

  // 暂停渲染。
  pause() {
    if (this.audioRenderer !== undefined) {
      // 只有渲染器状态为running的时候才能暂停。
      if (this.audioRenderer.state.valueOf() !== audio.AudioState.STATE_RUNNING) {
        return;
      }
      // 暂停渲染。
      this.audioRenderer.pause((err: BusinessError) => {
      });
    }
  }

  //设置速度
  setSpeed(value: number) {
    try {
      if (this.audioRenderer !== undefined) {

        // 暂停渲染。
        this.audioRenderer.setSpeed(value);
      }
    } catch (error) {
    }
  }

  // 停止渲染。
  stop() {
    if (this.audioRenderer !== undefined) {
      // 只有渲染器状态为running或paused的时候才可以停止。
      if (this.audioRenderer.state.valueOf() !== audio.AudioState.STATE_RUNNING &&
        this.audioRenderer.state.valueOf() !== audio.AudioState.STATE_PAUSED) {
        return;
      }
      // 停止渲染。
      this.audioRenderer.stop((err: BusinessError) => {
        if (err) {
        } else {
          this.callBack?.stopCallBack()
        }
      });
    }
  }

  // 销毁实例，释放资源。
  release() {
    if (this.audioRenderer !== undefined) {
      // 渲染器状态不是released状态，才能release。
      if (this.audioRenderer.state.valueOf() === audio.AudioState.STATE_RELEASED) {
        return;
      }
      // 释放资源。
      this.audioRenderer.release((err: BusinessError) => {
        if (err) {
        } else {
          if (this.file) {
            fs.closeSync(this.file)
            this.file = undefined
          }
        }
      });
    }
  }
}