import { audio } from '@kit.AudioKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { RcpDownloader } from 'chat_window';

// 与使用AudioRenderer开发音频播放功能过程相似，关键区别在于audioRendererInfo参数和音频数据来源。
const TAG = 'VoIPDemoForAudioRenderer';

export type PlayStatusCallBack = (status: boolean) => void

class Options {
  offset?: number;
  length?: number;
}

const audioStreamInfo: audio.AudioStreamInfo = {
  samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_16000, // 采样率
  channels: audio.AudioChannel.CHANNEL_1, // 通道
  sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE, // 采样格式
  encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW // 编码格式
};

const audioRendererInfo: audio.AudioRendererInfo = {
  // 需使用通话场景相应的参数。
  usage: audio.StreamUsage.STREAM_USAGE_VOICE_MESSAGE, // 音频流使用类型：语音消息。
  rendererFlags: 0 // 音频渲染器标志：默认为0即可。
};

const audioRendererOptions: audio.AudioRendererOptions = {
  streamInfo: audioStreamInfo,
  rendererInfo: audioRendererInfo
};


export class AudioRendererUtil {
  bufferSize: number = 0;
  audioRenderer: audio.AudioRenderer | undefined = undefined;
  file: fs.File | undefined = undefined
  private static _instance: AudioRendererUtil
  playStatusCallBack: PlayStatusCallBack | undefined = undefined
  url: string = ''
  private downloader?: RcpDownloader

  static getInstance() {
    if (!AudioRendererUtil._instance) {
      AudioRendererUtil._instance = new AudioRendererUtil()
    }
    return AudioRendererUtil._instance
  }

  writeDataCallback: audio.AudioRendererWriteDataCallback = (buffer: ArrayBuffer) => {
    let options: Options = {
      offset: this.bufferSize,
      length: buffer.byteLength
    };

    try {
      let bufferLength = fs.readSync(this.file?.fd, buffer, options);
      if (bufferLength === 0) { //播放完成
        this.stop()
      }
      this.bufferSize += buffer.byteLength;
      // 如果当前回调传入的数据不足一帧，空白区域需要使用静音数据填充，否则会导致播放出现杂音。
      if (bufferLength < buffer.byteLength) {
        let view = new DataView(buffer);
        for (let i = bufferLength; i < buffer.byteLength; i++) {
          // 空白区域填充静音数据。当使用音频采样格式为SAMPLE_FORMAT_U8时0x7F为静音数据，使用其他采样格式时0为静音数据。
          view.setUint8(i, 0);
        }
      }
      // API version 11不支持返回回调结果，从API version 12开始支持返回回调结果。
      // 如果开发者不希望播放某段buffer，返回audio.AudioDataCallbackResult.INVALID即可。
      return audio.AudioDataCallbackResult.VALID;
    } catch (error) {
      // API version 11不支持返回回调结果，从API version 12开始支持返回回调结果。
      return audio.AudioDataCallbackResult.INVALID;
    }
  }

  setFile(filePath: string) {
    this.file = fs.openSync(filePath, fs.OpenMode.READ_ONLY);
  }

  setPlayStatusCallBack(playStatusCallBack: PlayStatusCallBack) {
    this.playStatusCallBack = playStatusCallBack
  }

  // 初始化，创建实例，设置监听事件。
  async init() {
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

  // 开始一次音频渲染。
  async start(url: string) {
    this.url = url
    if (!this.file) {
      return
    }
    if (this.audioRenderer !== undefined) {
      let stateGroup = [audio.AudioState.STATE_PREPARED, audio.AudioState.STATE_PAUSED, audio.AudioState.STATE_STOPPED];
      if (stateGroup.indexOf(this.audioRenderer.state.valueOf()) === -1) { // 当且仅当状态为prepared、paused和stopped之一时才能启动渲染。
        return;
      }
      // 启动渲染。
      this.audioRenderer.start((err: BusinessError) => {
        if (err) {
        } else {
          if (this.playStatusCallBack) {
            this.playStatusCallBack(true)
          }
        }
      });
    }
  }

  // 暂停渲染。
  async pause() {
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

  // 停止渲染。
  async stop() {
    this.reset()
    if (this.audioRenderer !== undefined) {
      // 只有渲染器状态为running或paused的时候才可以停止。
      if (this.audioRenderer.state.valueOf() !== audio.AudioState.STATE_RUNNING &&
        this.audioRenderer.state.valueOf() !== audio.AudioState.STATE_PAUSED) {
        return;
      }
      // 停止渲染。
      this.audioRenderer.stop().then(() => {
        if (this.playStatusCallBack) {
          this.playStatusCallBack(false)
        }
      }).catch((err: BusinessError) => {
      })
    }
  }

  async reset() {
    if (this.file) {
      await fs.close(this.file);
    }
    this.file = undefined
    this.bufferSize = 0
  }

  // 销毁实例，释放资源。
  async release() {
    if (this.audioRenderer !== undefined) {
      // 渲染器状态不是released状态，才能release。
      if (this.audioRenderer.state.valueOf() === audio.AudioState.STATE_RELEASED) {
        return;
      }
      // 释放资源。
      this.audioRenderer.release((err: BusinessError) => {
        if (err) {
        } else {
          this.reset()
        }
      });
    }
  }

  /*
   * 设置输出设备
   */
  setOutDevice(deviceType = audio.DeviceType.EARPIECE) {
    this.audioRenderer?.setDefaultOutputDevice(deviceType)
  }

  /*
  * 准备音频文件
  */
  async readySoundFile(url: string | undefined, uiContext: UIContext | undefined) {
    if (!url || !uiContext) {
      return
    }
    if (url !== this.url) {
      this.url = url
      await this.stop()
    }
    let fileName: string = url.split('/').pop() as string
    fileName = fileName.split('?')[0]
    const dir: string = uiContext.getHostContext()?.cacheDir + '/downloads/'
    const fullPath = dir + fileName
    if (fs.accessSync(fullPath)) { //语音文件存在
      this.setFile(fullPath)
    } else { //语音文件不存在
      if (!this.downloader) {
        this.downloader = new RcpDownloader(uiContext.getHostContext() as common.UIAbilityContext)
      }
      try {
        await this.downloader?.startDownload(url, fileName)
        this.readySoundFile(url, uiContext)
      } catch (err) {
        uiContext.getPromptAction().showToast({ message: '语音加载失败' })
      }
    }
  }
}
