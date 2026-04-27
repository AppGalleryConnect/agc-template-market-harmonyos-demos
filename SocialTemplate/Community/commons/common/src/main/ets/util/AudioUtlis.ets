import { media } from '@kit.MediaKit';
import { audio } from '@kit.AudioKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { FriendUserInfo, UserInfo } from '../model/UserInfo';
import { PersistenceV2 } from '@kit.ArkUI';
import { GlobalContext } from '../basic/GlobalContext';

@ObservedV2
export class AudioUtlis {
  private soundPool: media.SoundPool | undefined = undefined
  private soundId: number = 0;
  private streamId: number = 0;
  @Trace specialConcern: boolean = false
  friendUserInfo: FriendUserInfo = PersistenceV2.connect(FriendUserInfo, () => new FriendUserInfo())!;

  constructor(userId: string) {
    this.friendUserInfo.userInfoList.forEach((groupInfo: UserInfo) => {
      if (groupInfo.id.includes(userId)) {
        this.specialConcern = true
      } else {
        this.specialConcern = false
      }
    })
    this.create();
  }

  async create() {
    try {
      // audioRenderInfo中的参数usage取值为STREAM_USAGE_UNKNOWN，STREAM_USAGE_MUSIC，STREAM_USAGE_MOVIE。
      // STREAM_USAGE_AUDIOBOOK时，SoundPool播放短音时为混音模式，不会打断其他音频播放。
      let audioRendererInfo: audio.AudioRendererInfo = {
        usage: audio.StreamUsage.STREAM_USAGE_RINGTONE, // 音频流使用类型：铃声。根据业务场景配置，参考StreamUsage。
        rendererFlags: 1 // 音频渲染器标志。
      }
      //创建soundPool实例。
      if (canIUse('SystemCapability.Multimedia.Media.SoundPool')) {
        this.soundPool = await media.createSoundPool(14, audioRendererInfo);
      }
      //注册监听。
      this.loadCallback();
      this.finishPlayCallback();
      this.setErrorCallback();

      // 加载音频资源。
      if (this.specialConcern) {
        let context = GlobalContext.getUIAbilityContext();
        // 获取输入文件fd，test.ogg为rawfile目录下的预置资源，需要开发者根据实际情况进行替换。
        let fileDescriptor = await context!.resourceManager.getRawFd('specialprompttone.wav');
        if (canIUse('SystemCapability.Multimedia.Media.SoundPool')) {
          this.soundId = await this.soundPool!.load(fileDescriptor.fd, fileDescriptor.offset, fileDescriptor.length);
        }
      } else {
        let context = GlobalContext.getUIAbilityContext();
        // 获取输入文件fd，test.ogg为rawfile目录下的预置资源，需要开发者根据实际情况进行替换。
        let fileDescriptor = await context!.resourceManager.getRawFd('prompttone.wav');
        if (canIUse('SystemCapability.Multimedia.Media.SoundPool')) {
          this.soundId = await this.soundPool!.load(fileDescriptor.fd, fileDescriptor.offset, fileDescriptor.length);
        }
      }
    } catch (e) {
    }
  }

  async loadCallback() {
    // 加载完成回调。
    if (canIUse('SystemCapability.Multimedia.Media.SoundPool')) {
      this.soundPool!.on('loadComplete', (soundId_: number) => {
        this.soundId = soundId_;
      })
    }
  }

  //设置播放完成监听。
  async finishPlayCallback() {
    if (canIUse('SystemCapability.Multimedia.Media.SoundPool')) {
      this.soundPool!.on('playFinished', () => {
        //完成后延迟释放
        this.release();
      })
    }
  }

  //设置错误类型监听。
  async setErrorCallback() {
    if (canIUse('SystemCapability.Multimedia.Media.SoundPool')) {
      this.soundPool!.on('error', (error: BusinessError) => {
      })
    }
  }

  async PlaySoundPool() {
    let playParameters: media.PlayParameters = {
      loop: 0, // 循环1次，即播放2次。
      rate: audio.AudioRendererRate.RENDER_RATE_NORMAL, // 正常倍速。
      leftVolume: 1.00, // 取值范围0.0-1.0。
      rightVolume: 1.00, // 取值范围0.0-1.0。
      priority: 0, // 最低优先级。
    };
    // 开始播放，这边play也可带播放播放的参数PlayParameters，请在音频资源加载完毕，即收到loadComplete回调之后再执行play操作。
    if (canIUse('SystemCapability.Multimedia.Media.SoundPool')) {
      this.soundPool!.play(this.soundId, playParameters, (error, streamID: number) => {
        if (error) {
        } else {
          this.streamId = streamID;
        }
      });
      // 设置循环播放次数。
      await this.soundPool!.setLoop(this.streamId, 0);

      // 设置对应流的优先级。
      await this.soundPool!.setPriority(this.streamId, 1);

      // 设置音量。
      await this.soundPool!.setVolume(this.streamId, 1.00 , 1.00);
    }
  }

  async release() {
    // 终止指定流的播放。
    if (canIUse('SystemCapability.Multimedia.Media.SoundPool')) {
      await this.soundPool!.stop(this.streamId);
      // 卸载音频资源。
      await this.soundPool!.unload(this.soundId);
      //关闭监听。
      this.setOffCallback();
      // 释放SoundPool。
      await this.soundPool!.release();
    }
  }

  async setOffCallback() {
    if (canIUse('SystemCapability.Multimedia.Media.SoundPool')) {
      this.soundPool!.off('loadComplete');
      this.soundPool!.off('playFinished');
      this.soundPool!.off('error');
    }
  }
}