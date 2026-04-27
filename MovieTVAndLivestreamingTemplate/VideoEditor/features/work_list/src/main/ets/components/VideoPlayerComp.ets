import { WorkViewModel } from 'video_common';

interface DurationObject {
  duration: number;
}

interface TimeObject {
  time: number;
}

interface FullscreenObject {
  fullscreen: boolean;
}

const TAG = 'VideoPlayerComp';

/**
 * @usage: 用于视频播放的组件，支持播放、暂停、预览图展示。
 * 关键参数：controller视频控制器，videoWork作品视图模型，isPlay播放状态，aspect宽高比。
 * 包含if逻辑：当isPlay为false时显示播放按钮。
 * @layout: Stack布局。底层为Video播放器，顶层为播放按钮（居中对齐），播放时隐藏按钮。
 * @constraints:
 * @zhName: 视频播放组件
 * @fileType: component
 * @isGen: true
 */
@ComponentV2
export struct VideoPlayerComp {
  controller: VideoController = new VideoController();
  @Param videoWork: WorkViewModel = new WorkViewModel();
  @Local isPlay: boolean = false;
  @Local aspect: number = Number(this.videoWork.aspectRatio)

  aboutToDisappear(): void {
    this.controller.stop();
  }

  build() {
    Stack() {
      Video({
        controller: this.controller,
        src: this.videoWork.videoUrl,
        previewUri: this.videoWork.thumbnail, // 设置预览图
        currentProgressRate: PlaybackSpeed.Speed_Forward_1_00_X, // 设置播放速度
      })
        .width(this.aspect > 1 ? '100%' : undefined)
        .height(this.aspect <= 1 ? '100%' : undefined)
        .aspectRatio(this.aspect)
        .constraintSize({ maxWidth: '100%', maxHeight: '100%' })
        .autoPlay(false)
        .controls(true)
        .enableShortcutKey(false)
        .objectFit(ImageFit.Contain)
        .onStart(() => {
          this.isPlay = true;
        })
        .onPause(() => {
          this.isPlay = false;
        })
        .onFinish(() => {
          this.isPlay = false;
        })
        .onError(() => {
        })
        .onStop(() => {
        })
        .onPrepared((e?: DurationObject) => {
          if (e !== undefined) {
          }
        })
        .onSeeking((e?: TimeObject) => {
          if (e !== undefined) {
          }
        })
        .onSeeked((e?: TimeObject) => {
          if (e !== undefined) {
          }
        })
        .onUpdate((e?: TimeObject) => {
          if (e !== undefined) {
          }
        })
        .onFullscreenChange((e?: FullscreenObject) => {
          if (e !== undefined) {
          }
        })
      // 播放按钮
      if (!this.isPlay) {
        Row() {
          Image($r('app.media.video_play_icon'))
            .width(20)
            .height(20)
        }
        .width(60)
        .height(60)
        .borderRadius(60)
        .backgroundColor('#66000000')
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
    .constraintSize({ maxWidth: '100%', maxHeight: '100%' })
    .onClick(() => {
      this.isPlay = !this.isPlay;
      if (this.isPlay) {
        this.controller.start()
      } else {
        this.controller.pause()
      }
    })
  }
}
