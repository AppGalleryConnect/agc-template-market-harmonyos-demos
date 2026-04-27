import { SimpleProgressBar } from './SimpleProgressBar';
import { CastService } from '../service/CastService';
import { toastUtil } from '../util/ToastUtil';

@ComponentV2
export struct CastingLayer {
  @Param @Require castService: CastService;
  @Param title: string = '';
  // 左右切换
  @Param isSwitch: boolean = true;
  @Event onPlayNext: Function;
  @Event onPlayPre: Function;
  @Event onPlay: Function;
  @Event onSeek: Function;
  @Event onBack: Function;

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        Header({
          title: this.title,
          onBack: this.onBack,
        });

        Scroll() {
          Column() {
            DeviceView({
              castService: this.castService,
            })
              .margin({ top: 9 });

            SimpleProgressBar({
              castService: this.castService,
            })
              .margin({ top: 24 })
              .width('100%')
              .padding({ left: 16, right: 16 });

            ControlView({
              castService: this.castService,
              onPlay: this.onPlay,
              onPlayNext: this.onPlayNext,
              onPlayPre: this.onPlayPre,
              isSwitch: this.isSwitch,
            })
              .margin({ top: 59 });
            ExitCastView({
              castService: this.castService,
            })
              .margin({ top: 40 });
          }.padding({ bottom: 12 });
        }.layoutWeight(1).scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false });

      };
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_primary'));
  }
}

@ComponentV2
struct Header {
  @Param title: string = '';
  @Event onBack: Function;

  build() {
    Row({ space: 8 }) {
      Image($r('app.media.ic_cast_left'))
        .width(40)
        .aspectRatio(1)
        .onClick(() => {
          this.onBack?.();
        });
      Text(this.title)
        .height(40)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Title_S'))
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis });
    }
    .justifyContent(FlexAlign.Start)
    .height(56)
    .width('100%')
    .padding({ left: 16, right: 16 });
  }
}

@ComponentV2
struct ExitCastView {
  @Param @Require castService: CastService;

  build() {
    Button({ type: ButtonType.Capsule }) {
      Row({ space: 8 }) {
        SymbolGlyph($r('sys.symbol.power'))
          .fontColor([$r('sys.color.icon_emphasize')])
          .fontSize(20);
        Text('退出投屏')
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium);
      }.alignItems(VerticalAlign.Center);
    }
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .height(40)
    .width(128)
    .onClick(() => {
      this.castService.endCasting();
    });
  }
}

@ComponentV2
struct DeviceView {
  @Param @Require castService: CastService;

  build() {
    Column() {
      Column() {
        Text('投屏设备:')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .lineHeight(21);
        Text(this.castService.castStatusModel.currentDeviceName)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .lineHeight(21);

      }.margin({ top: 49 });

    }
    .width(280)
    .height(167)
    .backgroundImage($r('app.media.tv_bg'))
    .backgroundImageSize(ImageSize.Contain);
  }
}

@ComponentV2
struct ControlView {
  @Param isSwitch: boolean = true;
  @Param @Require castService: CastService;
  @Event onPlayNext: Function;
  @Event onPlayPre: Function;
  @Event onPlay: Function;

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Image($r('app.media.bigCircle'))
        .width(208)
        .height(208);
      Image($r('app.media.innerCircle'))
        .width(72)
        .height(72);

      Column() {
        SymbolGlyph($r('sys.symbol.speaker_plus'))
          .fontSize(32)
          .fontColor([$r('sys.color.icon_primary')])
          .onClick(() => {
            toastUtil.showToast('音量+');
            this.castService.setVolumeByOffset(1);
          });
        SymbolGlyph($r('sys.symbol.speaker_minus'))
          .fontSize(32)
          .fontColor([$r('sys.color.icon_primary')])
          .onClick(() => {
            toastUtil.showToast('音量-');
            this.castService.setVolumeByOffset(-1);
          });
      }.height('100%')
      .padding({ top: 20, bottom: 20 })
      .justifyContent(FlexAlign.SpaceBetween);

      Row() {
        SymbolGlyph($r('sys.symbol.backward_end_fill'))
          .fontSize(32)
          .fontColor(this.isSwitch ? [$r('sys.color.icon_primary')] : ['rgba(0, 0, 0, 0.1)'])
          .onClick(() => {
            if (this.isSwitch) {
              this.onPlayPre?.();
            }
          });
        SymbolGlyph($r('sys.symbol.forward_end_fill'))
          .fontSize(32)
          .fontColor(this.isSwitch ? [$r('sys.color.icon_primary')] : ['rgba(0, 0, 0, 0.1)'])
          .onClick(() => {
            if (this.isSwitch) {
              this.onPlayNext?.();
            }
          });
      }.width('100%')
      .padding({ left: 20, right: 20 })
      .justifyContent(FlexAlign.SpaceBetween);

      Column() {
        SymbolGlyph(this.castService.castStatusModel.isCastPlaying ? $r('sys.symbol.pause') :
          $r('sys.symbol.play_fill'))
          .fontSize(40)
          .fontColor([$r('sys.color.icon_primary')]);
      }.justifyContent(FlexAlign.Center)
      .width(40)
      .height(40)
      .onClick(() => {
        this.castService.castStatusModel.isCastPlaying ? this.castService.pause() : this.castService.play();
      });
    }.width(208)
    .height(208);
  }
}

