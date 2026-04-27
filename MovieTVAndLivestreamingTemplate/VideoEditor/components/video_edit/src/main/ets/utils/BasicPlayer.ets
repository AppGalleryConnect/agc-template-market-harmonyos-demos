import { media } from '@kit.MediaKit';
import { fileIo } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';

export class BasicPlayer {
  // surfaceID用于播放画面显示，具体的值需要通过XComponent接口获取
  private surfaceID: string = '';
  private static avPlayerBasic: media.AVPlayer | null = null;
  private status: string = '';
  public currentTime: number = 0;

  public async initPlayer(url: string) {
    // 创建avPlayer实例对象
    try {
      let avPlayer: media.AVPlayer = await media.createAVPlayer();
      // 创建状态机变化回调函数
      this.setPipPlayerCallback(avPlayer);
      let filePath: string = url;
      // 打开文件获取fd
      let file = await fileIo.open(filePath, fileIo.OpenMode.READ_ONLY);
      let fdPath = `fd://${file.fd}`;
      avPlayer.url = fdPath;
      BasicPlayer.avPlayerBasic = avPlayer;
    } catch (error) {}
  }

  // 注册avplayer回调函数
  setPipPlayerCallback(avPlayer: media.AVPlayer) {
    // startRenderFrame首帧渲染回调函数
    avPlayer.on('startRenderFrame', () => {
      // 获取封面组件并隐藏
    })
    // seek操作结果回调函数
    avPlayer.on('seekDone', (seekDoneTime: number) => {
    })
    // error回调监听函数,当avPlayer在操作过程中出现错误时调用reset接口触发重置流程
    avPlayer.on('error', (err: BusinessError) => {
      // 调用reset重置资源，触发idle状态
      avPlayer.reset();
    })
    avPlayer.on('timeUpdate', (time: number) => {
      this.currentTime = time;
    });
    avPlayer.on('durationUpdate', (time: number) => {

    });
    // 状态机变化回调函数
    avPlayer.on('stateChange', async (state: string, reason: media.StateChangeReason) => {
      switch (state) {
        case 'idle':
          break;
        case 'initialized':
          // 设置surfaceID
          avPlayer.surfaceId = this.surfaceID;
          avPlayer.prepare();
          break;
        case 'prepared':
          avPlayer.seek(0)
          break;
        case 'playing':
          this.status = state;
          break;
        case 'paused':
          this.status = state;
          break;
        case 'completed':
          //调用播放结束接口
          avPlayer.stop();
          break;
        case 'stopped':
          // 调用prepare接口初始化avplayer状态重播
          avPlayer.prepare();
          break;
        case 'released':
          break;
        default:
          break;
      }
    })
  }

  // 切换播放暂停状态
  switchPlayOrPause() {
    if (BasicPlayer.avPlayerBasic === null) {
      return;
    }
    if (this.status === 'playing') {
      BasicPlayer.avPlayerBasic.pause();
    } else {
      BasicPlayer.avPlayerBasic.play();
    }
  }

  // 播放
  play() {
    BasicPlayer.avPlayerBasic?.play();
  }

  // 暂停
  pause() {
    BasicPlayer.avPlayerBasic?.pause();
  }


  // 传入surface id
  setSurfaceID(surfaceId: string) {
    this.surfaceID = surfaceId;
  }

  getPlayer(): media.AVPlayer | null {
    return BasicPlayer.avPlayerBasic;
  }

  // 设置静音
  setToMuteMode() {
    BasicPlayer.avPlayerBasic?.setMediaMuted(media.MediaType.MEDIA_TYPE_AUD, true);
  }

  // 取消静音
  cancelMuteMode() {
    BasicPlayer.avPlayerBasic?.setMediaMuted(media.MediaType.MEDIA_TYPE_AUD, false);
  }

  //播放到指定时间
  seekTo(time: number) {
    BasicPlayer.avPlayerBasic?.seek(time * 1000)
  }
}