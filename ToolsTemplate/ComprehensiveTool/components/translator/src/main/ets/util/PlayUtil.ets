import { UtilLog } from '@hw-agconnect/util-log';
import { media } from '@kit.MediaKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { audio } from '@kit.AudioKit';
import { TranLogger } from './TranLogger';


export class PlayUtil {
  private fd: number = 0;
  private avPlayer: media.AVPlayer | null = null;
  // 播放完成
  public onCompleted: () => void = () => {

  };
  // 准备完成
  public onPrepared: (duration: number) => void = () => {

  };
  // 时间更新上报
  public onTimeUpdate: (time: number) => void = () => {

  };
  // 跳转上报
  public onSeekDone: (time: number) => void = () => {

  };

  // 以下demo为使用fs文件系统打开沙箱地址获取媒体文件地址并通过url属性进行播放示例
  async playerUrlInit(path: string) {
    try {
      // 创建avPlayer实例对象
      this.avPlayer = await media.createAVPlayer();
      // 创建状态机变化回调函数
      this.setAVPlayerCallback(this.avPlayer);
      let fdPath = 'fd://';
      // 打开相应的资源文件地址获取fd，并为url赋值触发initialized状态机上报
      let file = await fs.open(path);
      // 保存文件路径，实例销毁时关闭
      this.fd = file.fd
      fdPath = fdPath + '' + file.fd;
      this.avPlayer.url = fdPath;
    } catch (e) {
      UtilLog.error(`playerUrlInit failed: ${JSON.stringify(e)}`);
    }
  }

  play(): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.play();
      } catch (e) {
        TranLogger.error(JSON.stringify(e));
      }
    }
  }

  pause(): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.pause();
      } catch (e) {
        TranLogger.error(JSON.stringify(e));
      }
    }
  }

  stop(): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.stop();
      } catch (e) {
        TranLogger.error(JSON.stringify(e));
      }
    }
  }

  released(): void {
    if (this.avPlayer) {
      try {
        this.avPlayer.release();
        // 实例销毁时同时关闭文件流
        fs.closeSync(this.fd)
      } catch (e) {
        TranLogger.error(JSON.stringify(e));
      }
    }
  }


  // 注册avplayer回调函数
  private setAVPlayerCallback(avPlayer: media.AVPlayer) {
    // seek操作结果回调函数
    avPlayer.on('seekDone', (seekDoneTime: number) => {
      avPlayer.play();
      this.onSeekDone(seekDoneTime / 1000);
      TranLogger.info(`AVPlayer seek succeeded, seek time is ${seekDoneTime}`);
    });
    // error回调监听函数,当avPlayer在操作过程中出现错误时调用 reset接口触发重置流程
    avPlayer.on('error', (err: BusinessError) => {
      TranLogger.error(`Invoke avPlayer failed, code is ${err.code}, message is ${err.message}`);
      avPlayer.reset(); // 调用reset重置资源，触发idle状态
    });
    // 时间更新上报
    avPlayer.on('timeUpdate', (time: number) => {
      this.onTimeUpdate(time / 1000);
    });
    // 状态机变化回调函数
    avPlayer.on('stateChange', async (state: string, reason: media.StateChangeReason) => {
      switch (state) {
        case 'idle': // 成功调用reset接口后触发该状态机上报
          TranLogger.info('AVPlayer state idle called.');
          break;
        case 'initialized': // avplayer 设置播放源后触发该状态上报
          TranLogger.info('AVPlayer state initialized called.');
          avPlayer.audioRendererInfo = {
            usage: audio.StreamUsage.STREAM_USAGE_MUSIC,
            rendererFlags: 0,
          };
          avPlayer.prepare();
          break;
        case 'prepared': // prepare调用成功后上报该状态机
          TranLogger.info('AVPlayer state prepared called.');
          this.onPrepared(avPlayer.duration / 1000);
          break;
        case 'playing': // play成功调用后触发该状态机上报
          TranLogger.info('AVPlayer state playing called.');
          break;
        case 'paused': // pause成功调用后触发该状态机上报
          TranLogger.info('AVPlayer state paused called.');
          break;
        case 'completed': // 播放结束后触发该状态机上报
          this.onCompleted();
          TranLogger.info('AVPlayer state completed called.');
          avPlayer.stop(); //调用播放结束接口
          break;
        case 'stopped': // stop接口成功调用后触发该状态机上报
          TranLogger.info('AVPlayer state stopped called.');
          avPlayer.prepare(); // 播放完成重新准备
          break;
        case 'released':
          TranLogger.info('AVPlayer state released called.');
          break;
        default:
          TranLogger.info('AVPlayer state unknown called.');
          break;
      }
    });
  }
}