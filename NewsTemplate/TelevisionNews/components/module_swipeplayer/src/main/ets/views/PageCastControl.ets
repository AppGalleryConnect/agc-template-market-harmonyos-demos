import { AVCastPicker } from '@kit.AVSessionKit';
import { PageCastControlVM } from '../viewmodel/PageCastControlVM';
import { Constants } from '../constants/Constants';
import { ControlPanel } from '../components/ControlPanel';

@Builder
export function PageCastControlBuilder() {
  PageCastControl()
}

@ComponentV2
export struct PageCastControl {
  @Local vm: PageCastControlVM = new PageCastControlVM();

  aboutToAppear(): void {
    this.vm.uiContext = this.getUIContext();
  }

  aboutToDisappear(): void {
    this.vm.offListeners();
  }

  build() {
    NavDestination() {
      Column() {
        this.titleBuilder()
        Flex({
          justifyContent: FlexAlign.SpaceBetween,
          direction: this.vm.isSplit ? FlexDirection.Row : FlexDirection.Column,
        }) {
          Column() {
            this.deviceInfoBuilder()
            Column({ space: Constants.PADDING_M }) {
              this.progressBarBuilder()
              this.tipBuilder()
            }
            .reverse(this.vm.isSplit)
          }
          .columnStyle(this.vm.isSplit)

          Column() {
            this.controlPanelBuilder()
            this.quitCastBuilder()
          }
          .columnStyle(this.vm.isSplit)
        }
        .width(Constants.FULL_PERCENT)
        .layoutWeight(1)
        .padding({
          top: Constants.PADDING_M,
          bottom: Constants.PADDING_8XL,
        })
      }
      .width(Constants.FULL_PERCENT)
      .height(Constants.FULL_PERCENT)
      .alignItems(HorizontalAlign.Start)
      .padding({
        left: Constants.PADDING_L,
        right: Constants.PADDING_L,
        top: 28,
      })
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
    .onReady((context) => {
      this.vm.initParams(context);
    })
    .onBackPressed(() => {
      this.vm.onBackPress();
      return true;
    })
  }

  @Builder
  deviceInfoBuilder() {
    Column() {
      Stack() {
        Image($r('app.media.cast_device'))
          .width(Constants.FULL_PERCENT)
          .draggable(false)
        Column({ space: Constants.SPACE_L }) {
          Text() {
            Span('投屏设备：')
            Span(this.vm.videoCastController?.deviceName)
          }
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)

          Row({ space: Constants.SPACE_XS }) {
            Image($r('app.media.ic_record'))
              .width(16)
              .height(16)
            Text('720P标清')
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
          }
          .height(28)
          .borderRadius(14)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .padding({
            top: Constants.PADDING_XS,
            bottom: Constants.PADDING_XS,
            left: Constants.PADDING_S,
            right: Constants.PADDING_S,
          })
        }
        .padding(Constants.PADDING_S)
      }
      .width(this.vm.isSplit ? 400 : 280)
      .alignContent(Alignment.Center)
    }
    .layoutWeight(this.vm.isSplit ? 1 : 0)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  tipBuilder() {
    Column() {
      if (this.vm.disconnected) {
        Text('你的电视已退出投屏')
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_primary'))
      }

      if (this.vm.connecting) {
        Text('投屏连接中，请稍后...')
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_primary'))
      }

      if (this.vm.isPlayOver && !this.vm.isPlaying) {
        Text() {
          Span('播放已结束，点击')
            .fontColor($r('sys.color.font_primary'))
          Span('重新播放')
            .fontColor(this.vm.globalConfigModel.themeColor)
            .onClick(() => {
              this.vm.reStart();
            })
        }
        .fontSize($r('sys.float.Body_M'))
      }
    }
  }

  @Builder
  progressBarBuilder() {
    Row({ space: Constants.SPACE_M }) {
      Text(this.vm.currentStringTime)
        .fontSize($r('sys.float.Caption_M'))
        .fontColor($r('sys.color.font_primary'))
      Slider({
        value: this.vm.currentTime,
        step: 1000,
        min: 0,
        max: this.vm.durationTime,
        style: SliderStyle.OutSet,
      })
        .enabled(!this.vm.disableOperate)
        .blockColor($r('app.color.cast_slider_block'))
        .layoutWeight(1)
        .onChange((value: number, mode: SliderChangeMode) => {
          this.vm.onSliderChange(value, mode);
        })
      Text(this.vm.durationStringTime)
        .fontSize($r('sys.float.Caption_M'))
        .fontColor($r('sys.color.font_primary'))
    }
    .width(Constants.FULL_PERCENT)
    .height(40)
    .margin({
      top: Constants.PADDING_2XL,
    })
  }

  @Builder
  controlPanelBuilder() {
    Column() {
      ControlPanel({
        isPlaying: this.vm.isPlaying,
        isLargeSize: this.vm.isSplit,
        playOrPause: () => {
          if (this.vm.isPlaying) {
            this.vm.videoCastController?.pause();
          } else {
            this.vm.videoCastController?.play();
          }
        },
        setVolume: (volume: number) => {
          this.vm.videoCastController?.setVolume(volume);
        },
      })
    }
    .layoutWeight(this.vm.isSplit ? 1 : 0)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  quitCastBuilder() {
    Button() {
      Row({ space: Constants.SPACE_S }) {
        SymbolGlyph($r('sys.symbol.power'))
          .fontColor([$r('sys.color.font_primary')])
          .fontWeight(FontWeight.Normal)
          .fontSize(24)

        Text('退出投屏')
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
      }
    }
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .width(this.vm.isSplit ? 188 : 128)
    .height(40)
    .margin({
      top: Constants.PADDING_4XL,
    })
    .onClick(() => {
      this.vm.quitCastVideo();
    })
  }

  @Builder
  customCastBuilder() {
    Button() {
      SymbolGlyph($r('sys.symbol.control'))
        .fontColor([$r('sys.color.font_primary')])
        .fontWeight(FontWeight.Normal)
        .fontSize(24)
    }
    .width(40)
    .height(40)
    .type(ButtonType.Circle)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
  }

  @Builder
  titleBuilder() {
    Row({ space: Constants.SPACE_S }) {
      Button() {
        SymbolGlyph($r('sys.symbol.chevron_backward'))
          .fontColor([$r('sys.color.font_primary')])
          .fontWeight(FontWeight.Normal)
          .fontSize(24)
      }
      .width(40)
      .height(40)
      .type(ButtonType.Circle)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onClick(() => {
        this.vm.onBackPress();
      })

      Text(this.vm.videoTitle)
        .fontSize($r('sys.float.Title_S'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)
        .textAlign(TextAlign.Start)

      AVCastPicker({
        customPicker: () => this.customCastBuilder(),
      })
        .width(40)
        .height(40)
    }
    .width(Constants.FULL_PERCENT)
    .padding({
      top: Constants.PADDING_S,
      bottom: Constants.PADDING_S,
    })
  }
}

@Extend(Column)
function columnStyle(isSplit: boolean) {
  .width(isSplit ? Constants.HALF_PERCENT : Constants.FULL_PERCENT)
  .height(isSplit ? Constants.FULL_PERCENT : 'auto')
  .justifyContent(FlexAlign.End)
}