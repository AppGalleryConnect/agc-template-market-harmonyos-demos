import media from '@ohos.multimedia.media'
import audio from '@ohos.multimedia.audio'
import { fileIo as fs } from '@kit.CoreFileKit';
import Logger from './Logger';

export class SoundPoolUtil {
  private static instance: SoundPoolUtil | null = null
  private soundPool: media.SoundPool | null = null
  private soundMap: Map<string, number> = new Map()
  private streamMap: Map<number, number> = new Map()
  private initPromise: Promise<void> | null = null;

  // 初始化SoundPool
  init(): Promise<void> {
    if (this.initPromise) {
      return this.initPromise;
    }

    this.initPromise = new Promise(async (resolve, reject) => {
      const audioRendererInfo: audio.AudioRendererInfo = {
        usage: audio.StreamUsage.STREAM_USAGE_MUSIC,
        rendererFlags: 0,
      };

      try {
        this.soundPool = await media.createSoundPool(5, audioRendererInfo);
        this.registerListeners();
        resolve();
      } catch (error) {
        Logger.error(`SoundPool初始化失败: ${error.message}`);
        reject(error);
      }
    });

    return this.initPromise;
  }

  private registerListeners() {
    if (!this.soundPool) {
      return
    }

    this.soundPool.on('loadComplete', (soundId: number) => {
      Logger.info('音频加载完成, soundId: ' + soundId)
    })

    this.soundPool.on('playFinished', () => {
      Logger.info('音频播放完成')
    })

    this.soundPool.on('error', (error) => {
      Logger.error('发生错误: ' + error.message)
    })
  }

  // 加载音频
  public async loadSound(filePath: string): Promise<number> { // 修复错误2：明确返回类型
    if (!this.soundPool) {
      return -1
    }
    if (this.soundMap.get(filePath)) {
      return -1;
    }
    let file: fs.File | undefined = undefined
    try {
      let uri = '';
      file = await fs.open(filePath, fs.OpenMode.READ_ONLY)
      uri = 'fd://' + (file.fd).toString()
      const soundId = await this.soundPool.load(uri)
      this.soundMap.set(filePath, soundId)
      return soundId
    } catch (error) { // 修复错误4：移除catch中的类型注解
      Logger.error(`音频加载失败: ${error.message}`)
      return -1;
    } finally {
      if (file) {
        fs.closeSync(file.fd)
      }
    }
  }


  // 播放音频
  async play(key: string, params?: media.PlayParameters): Promise<number | undefined> {
    if (!this.soundPool) {
      return undefined
    }

    const soundId = this.soundMap.get(key)
    if (!soundId) {
      Logger.error(`未找到音频: ${key}`)
      return undefined
    }

    const defaultParams: media.PlayParameters = {
      loop: 0,
      rate: audio.AudioRendererRate.RENDER_RATE_NORMAL,
      leftVolume: 1.0,
      rightVolume: 1.0,
      priority: 1,
    }

    try {
      const streamId = await this.soundPool.play(soundId, params || defaultParams)
      this.streamMap.set(soundId, streamId)
      return streamId
    } catch (error) { // 修复错误5：移除catch中的类型注解
      Logger.error(`播放失败: ${error.message}`)
      return undefined
    }
  }

  // 停止播放
  async stop(key: string) {
    if (!this.soundPool) {
      return
    }

    const soundId = this.soundMap.get(key)
    if (!soundId) {
      return
    }
    const streamId = this.streamMap.get(soundId)
    if (streamId) {
      await this.soundPool.stop(streamId)
      this.streamMap.delete(soundId)
    }
  }

  // 释放资源
  async release() {
    if (!this.soundPool) {
      Logger.info('SoundPool尚未初始化，无需释放');
      return;
    }

    try {
      Logger.info('开始释放SoundPool资源');

      // 停止所有播放
      for (const streamId of this.streamMap.values()) {
        await this.soundPool.stop(streamId);
      }
      this.streamMap.clear();

      // 卸载所有音频
      for (const soundId of this.soundMap.values()) {
        await this.soundPool.unload(soundId);
      }
      this.soundMap.clear();

      // 移除事件监听
      this.soundPool.off('loadComplete');
      this.soundPool.off('playFinished');
      this.soundPool.off('error');

      // 释放SoundPool实例
      await this.soundPool.release();

    } catch (error) {
      Logger.error(`释放SoundPool资源时发生错误: ${error.message}`);
    }
  }

  // 获取单例实例
  public static getInstance(): SoundPoolUtil {
    if (!SoundPoolUtil.instance) {
      SoundPoolUtil.instance = new SoundPoolUtil();
    }
    return SoundPoolUtil.instance;
  }

  // 静态播放方法
  public static async playSound(uri: string, volume: number = 1, instance: SoundPoolUtil): Promise<number | undefined> {
    try {
      // 确保 SoundPool 已初始化
      if (!instance.soundPool) {
        await instance.init();
      }

      // 加载并播放声音
      await instance.loadSound(uri);

      const params: media.PlayParameters = {
        loop: 0,
        rate: audio.AudioRendererRate.RENDER_RATE_NORMAL,
        leftVolume: volume,
        rightVolume: volume,
        priority: 1,
      };
      const result = instance.play(uri, params);
      return result;
    } catch (error) {
      Logger.error('播放音频失败:', error);
      return undefined;
    }
  }
}
