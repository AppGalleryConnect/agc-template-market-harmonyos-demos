import { image } from '@kit.ImageKit';
import sdk from 'libveditor.so';
import { Constant } from '../common/Constant';
import { AudioInfo } from '../model/Index';
import { VideoUtil } from '../util/VideoUtil';
import { VideoEditVM } from '../viewmodel/VideoEditVM';

@Extend(Row)
function handler(isLeft: boolean) {
  .clip(true)
  .width(20)
  .justifyContent(FlexAlign.Center)
  .gesture(PanGesture()
    .onActionStart((event: GestureEvent) => {
      if (!event || !event.fingerList[0]) {
        return;
      }
      // 拖动开始时调用后端接口暂停播放
      VideoEditVM.instance.dragStart(isLeft, event.fingerList[0].displayX);
    })
    .onActionUpdate((event: GestureEvent) => {
      if (!event || !event.fingerList[0]) {
        return;
      }
      VideoEditVM.instance.dragMoving(event.fingerList[0].displayX);
    })
    .onActionEnd((event: GestureEvent) => {
      if (!event || !event.fingerList[0]) {
        return;
      }
      VideoEditVM.instance.dragEnd();
    }),
  );
}

@ComponentV2
export struct VideoControlComponent {
  vm: VideoEditVM = VideoEditVM.instance;

  build() {
    Column() {
      Row() {
        Row() {
          Checkbox()
            .width(Constant.AUDIO_CONTROL_CIRCLE_SIZE)
            .height(Constant.AUDIO_CONTROL_CIRCLE_SIZE)
            .select(this.vm.keepVideoAudio)
            .enabled(!this.vm.durationError)
            .onChange((value) => {
              this.vm.keepVideoAudio = value;
              sdk.MuteVideo(!this.vm.keepVideoAudio);
            });
          Text('视频原声')
            .fontSize(14);
        };

        // 已选择音频时显示音频信息和删除按钮
        if (this.vm.selectedAudio.name.length) {
          Row({ space: 12 }) {
            Image($r('app.media.music')).size({ width: 16, height: 16 });

            Text(this.vm.selectedAudio.name)
              .fontSize(14)
              .fontColor($r('sys.color.font_primary'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis });

            Button('删除')
              .type(ButtonType.Normal)
              .borderRadius($r('sys.float.corner_radius_level4'))
              .size({ width: 72, height: 28 })
              .fontColor($r('sys.color.font_on_primary'))
              .backgroundColor($r('sys.color.warning'))
              .onClick(() => {
                sdk.UnsetBgAudio();
                this.vm.selectedAudio = new AudioInfo();
              });
          };
        }
      }.width('100%').justifyContent(FlexAlign.SpaceBetween).margin({ bottom: 12 });

      Row() {
        Text(`00:00`)
          .fontSize(12)
          .fontColor($r('sys.color.font_primary'));

        Text(`${VideoUtil.formatUsToMinSec(this.vm.curDuration)}`)
          .fontSize(12)
          .fontColor($r('sys.color.font_primary'));
      }.width('100%').justifyContent(FlexAlign.SpaceBetween).margin({ bottom: 24 });

      Stack() {
        if (this.vm.isInCut) {
          Row() {
            Row() {
              // 前全局把手
              Row() {
                Row()
                  .height(60)
                  .width('100%')
                  .backgroundColor(Color.Transparent);
              }
              .layoutWeight(1)
              .height(60);

              Row() {
                Blank()
                  .width(3)
                  .height(24)
                  .backgroundColor($r('sys.color.icon_on_primary'))
                  .borderRadius(3);
              }
              .height(60)
              .width(20)
              .backgroundColor($r('sys.color.comp_foreground_primary'))
              .borderRadius({ topLeft: 8, bottomLeft: 8 })
              .handler(true);
            }.width(this.vm.trimIn + 16);

            // 中间边框
            Blank()
              .width(this.vm.duration - this.vm.trimIn - this.vm.trimOut)
              .height(60)
              .border({ width: { top: 8, bottom: 8 }, color: $r('sys.color.comp_foreground_primary') });
            // 后全局把手
            Row() {
              Row() {
                Blank()
                  .width(3)
                  .height(24)
                  .backgroundColor($r('sys.color.icon_on_primary'))
                  .borderRadius(3);
              }
              .height(60)
              .width(20)
              .backgroundColor($r('sys.color.comp_foreground_primary'))
              .justifyContent(FlexAlign.Center)
              .borderRadius({ topRight: 8, bottomRight: 8 })
              .handler(false);

              Row() {
                Row()
                  .position({ x: -4, y: 0 })
                  .height(60)
                  .width('100%')
                  .backgroundColor(Color.Transparent);
              }
              .zIndex(-1)
              .layoutWeight(1)
              .height(60);
            }.height(60)
            .width(16 + this.vm.trimOut);
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')
          .zIndex(1);
        }

        Stack() {
          Row() {
            ForEach(this.vm.pixelMaps, (item: image.PixelMap) => {
              Image(item)
                .width(this.vm.duration / 6)
                .height(this.vm.laneHeight)
                .transition(TransitionEffect.OPACITY.animation({ duration: this.vm.duration, curve: Curve.EaseIn }))
                .objectFit(ImageFit.Fill);
            });
          }.width('100%').height('100%')
          .justifyContent(FlexAlign.Center);
        }
        .width('100%')
        .clip(true)
        .id('thumbnails');
      }.height(64);
    }.width('100%').padding({ left: 16, right: 16 });
  }
}