import { VoicePackage } from '../types/Types';
import { BroadCastUtil } from '../utils/BroadcastUtil';

@ComponentV2
export struct VoiceListItem {
  @Require @Param voice: VoicePackage;
  @Param cardRadius: number = 0;
  @Event callback: () => void;
  @Local progress: string = '下载';

  build() {
    ListItem() {
      Row() {
        Image(this.voice.pic)
          .width(56)
          .height(56)
          .borderRadius(12)

        Column() {
          Text(this.voice.desc)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Body_L'))
          Blank().layoutWeight(1)
          Text(this.voice.used + '万人正在使用')
            .fontColor($r('sys.color.font_secondary'))
            .fontSize($r('sys.float.Body_S'))
            .margin({ bottom: 3 })
          Row() {
            ForEach(Array.from({ length: this.voice.rate }), () => {
              Image($r('app.media.star')).width(14).aspectRatio(1).padding(1)
            }, (item: number, index) => index.toString())
            ForEach(Array.from({ length: 5 - this.voice.rate }), () => {
              Image($r('app.media.star_gray'))
                .width(14)
                .aspectRatio(1)
                .padding(1)
                .fillColor($r('sys.color.icon_secondary'))
            }, (item: number, index) => index.toString())
          }
        }
        .height('100%')
        .margin({ left: 16 })
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        this.buttonBuilder()
      }
      .height(56)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .backgroundColor($r('sys.color.comp_background_primary'))
    .borderRadius(this.cardRadius)
    .padding({
      left: 16,
      right: 16,
      top: 12,
      bottom: 12,
    })
  }

  @Builder
  buttonBuilder() {
    if (!this.voice.installed) {
      // 下载
      Text(this.progress).textStyle().onClick(() => {
        BroadCastUtil.downloadVoice(
          this.voice.type,
          () => {
            this.progress = '0%';
          },
          (progress) => {
            this.progress = progress;
          },
          () => {
            this.callback();
          },
        );
      })
    } else if (this.voice.type !== BroadCastUtil.getCurVoiceType()) {
      // 切换
      Text('使用').textStyle().onClick(() => {
        BroadCastUtil.change(this.voice.type);
      })
    } else {
      Stack() {
        Text('使用中').textStyle().opacity(0.4)
        Text('使用中')
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_on_primary'))
          .fontSize($r('sys.float.Body_M'))
      }
    }
  }
}

@Extend(Text)
function textStyle() {
  .width(72)
  .height(28)
  .borderRadius('50%')
  .textAlign(TextAlign.Center)
  .fontWeight(FontWeight.Medium)
  .fontColor($r('sys.color.font_on_primary'))
  .fontSize($r('sys.float.Body_M'))
  .backgroundColor('#3F7EF7')
}
