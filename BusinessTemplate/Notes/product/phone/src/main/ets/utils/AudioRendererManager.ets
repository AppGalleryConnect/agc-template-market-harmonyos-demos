/*
 * 从 VoiceInsertNote 迁移的播放实现：基于 AudioRenderer 播放 PCM 文件
 */
import { audio } from '@kit.AudioKit';
import { fileIo } from '@kit.CoreFileKit';
import { Constants } from './VoiceAudioConstants';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';

export class AudioRendererManager {
  private playFile?: fileIo.File;
  private fileSize: number = 0;
  private readOffset: number = 0;
  private sampleValCnt: number = 0;
  private sampleValSum: number = 0;
  private renderer?: audio.AudioRenderer;

  setReadOffset(offset: number) {
    this.readOffset = offset;
    this.renderer?.flush();
  }

  calculateDecibel(): number {
    if (this.sampleValCnt === 0) {
      return 0;
    }
    let rms = this.sampleValSum / this.sampleValCnt;
    let db = Math.max(Constants.MIN_DB, Math.min(0, 20 * Math.log10(rms)));
    this.sampleValCnt = 0;
    this.sampleValSum = 0;
    return (db + Math.abs(Constants.MIN_DB)) / Math.abs(Constants.MIN_DB);
  }

  rendererState(): audio.AudioState | undefined {
    if (this.renderer !== undefined) {
      return this.renderer.state;
    }
    return undefined;
  }

  async initRenderer() {
    let audioStreamInfo: audio.AudioStreamInfo = {
      channels: Constants.CHANNEL_NUM,
      samplingRate: Constants.SAMPLING_RATE,
      sampleFormat: Constants.SAMPLE_FORMAT,
      encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW,
    };
    let audioRendererInfo: audio.AudioRendererInfo = {
      rendererFlags: 0,
      usage: audio.StreamUsage.STREAM_USAGE_MUSIC,
    };
    let audioRendererOptions: audio.AudioRendererOptions = {
      streamInfo: audioStreamInfo,
      rendererInfo: audioRendererInfo,
    };

    this.renderer = await audio.createAudioRenderer(audioRendererOptions);

    try {
      this.renderer.on('stateChange', (state: audio.AudioState) => {
        hilog.info(0x0000, 'AudioRenderer', state.toString());
      });
    } catch (e) {
      hilog.error(0x0000, 'AudioRenderer', `register stateChange failed: ${JSON.stringify(e)}`);
    }

    try {
      this.renderer.on('writeData', (buffer: ArrayBuffer) => {
      let lastLen = this.fileSize - this.readOffset;
      let readLen = lastLen >= buffer.byteLength ? buffer.byteLength : lastLen;
      try {
        let actualReadLen = fileIo.readSync(this.playFile?.fd, buffer, { offset: this.readOffset, length: readLen });
        if (actualReadLen === 0) {
          hilog.error(0x000, 'No data was read from the file.', '');
          this.pauseRenderer();
        }
      } catch (e) {
        hilog.error(0x000, 'Failed to read file:', e);
        throw new Error('Failed to read file');
      }

      this.readOffset += readLen;
      AppStorage.setOrCreate('RWOffset', this.readOffset);

      if (this.readOffset >= this.fileSize) {
        AppStorage.setOrCreate('AudioAtEnd', true);
        // 到末尾则暂停，避免循环从头播放
        void this.pauseRenderer();
        // 保持在末尾位置，供 UI 判断/展示
        this.readOffset = this.fileSize;
      }

      let samples = new Int16Array(buffer);
      for (let i = 0; i < samples.length; i++) {
        let val = samples[i] / Constants.VOLUME_MAX;
        this.sampleValSum += val * val;
        this.sampleValCnt += 1;
      }
      });
    } catch (e) {
      hilog.error(0x0000, 'AudioRenderer', `register writeData failed: ${JSON.stringify(e)}`);
    }
  }

  async startRenderer(fileName?: string, context?: common.UIAbilityContext) {
    if (this.renderer === undefined) {
      throw new Error(`Realse AudioRederer at undefined state`);
    }
    let state = this.renderer.state;
    if (state === audio.AudioState.STATE_INVALID) {
      this.renderer = undefined;
      throw new Error(`Start AudioRenderer at invalid state.`);
    }

    if (fileName) {
      let pathDir = context?.cacheDir;
      let filePath = pathDir + `/${fileName}.pcm`;
      if (this.playFile?.path !== filePath) {
        if (this.playFile) {
          await fileIo.close(this.playFile);
          await this.renderer.flush();
        }
        this.playFile = await fileIo.open(filePath, fileIo.OpenMode.READ_ONLY);
      }
      this.fileSize = fileIo.statSync(filePath).size;
    }
    try {
      await this.renderer.start();
    } catch (e) {
      hilog.error(0x0000, 'AudioRenderer', `start failed: ${JSON.stringify(e)}`);
    }
  }

  async pauseRenderer() {
    if (this.renderer === undefined) {
      throw new Error(`Realse AudioRenderer at undefined state`);
    }
    let state = this.renderer.state;
    if (state === audio.AudioState.STATE_INVALID) {
      this.renderer = undefined;
      throw new Error(`Pause AudioRenderer at invalid state.`);
    }
    if (state !== audio.AudioState.STATE_RUNNING) {
      return;
    }
    await this.renderer.pause();
  }

  async stopRenderer() {
    if (this.renderer === undefined) {
      throw new Error(`Realse AudioRenderer at undefined state`);
    }
    let state = this.renderer.state;
    if (state === audio.AudioState.STATE_INVALID) {
      this.renderer = undefined;
      throw new Error(`Stop AudioRenderer at invalid state.`);
    }
    if (state !== audio.AudioState.STATE_RUNNING && state !== audio.AudioState.STATE_PAUSED) {
      return;
    }

    try {
      await this.renderer.stop();
    } catch (e) {
      hilog.error(0x0000, 'AudioRenderer', `stop failed: ${JSON.stringify(e)}`);
    }

    try {
      fileIo.closeSync(this.playFile?.fd);
    } catch (e) {
      hilog.error(0x0000, 'AudioRenderer', `close file failed: ${JSON.stringify(e)}`);
    }
  }

  async releaseRenderer() {
    if (this.renderer === undefined) {
      throw new Error(`Realse AudioRenderer at undefined state`);
    }
    let state = this.renderer.state;
    if (state === audio.AudioState.STATE_INVALID) {
      this.renderer = undefined;
      throw new Error(`Release AudioRenderer at invalid state.`);
    }
    if (state !== audio.AudioState.STATE_PAUSED && state !== audio.AudioState.STATE_STOPPED &&
      state !== audio.AudioState.STATE_PREPARED) {
      return;
    }
    try {
      await this.renderer.release();
    } catch (e) {
      hilog.error(0x0000, 'AudioRenderer', `release failed: ${JSON.stringify(e)}`);
    }
    this.renderer = undefined;
  }
}

