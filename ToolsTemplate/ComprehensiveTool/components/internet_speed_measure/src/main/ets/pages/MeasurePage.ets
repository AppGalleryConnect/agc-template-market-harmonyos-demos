import { CommonHeader } from '../components/CommonHeader';
import { SpeedCurve } from '../components/SpeedCurve';
import { SpeedGauge } from '../components/SpeedGauge';
import { MeasureStatus } from '../constants/Enum';
import { StyleConstants } from '../constants/Styles';
import { NetworkType } from '../types/NetworkType';
import { MeasureVM } from '../viewmodel/MeasureVM';

@Builder
export function measurePageBuilder() {
  MeasurePage();
}

@ComponentV2
export struct MeasurePage {
  vm: MeasureVM = MeasureVM.instance;
  @Local stack: NavPathStack | undefined;

  aboutToAppear(): void {
    this.vm.in(this.getUIContext());
  }

  aboutToDisappear(): void {
    this.vm.out();
  }

  build() {
    NavDestination() {
      if (this.stack) {
        CommonHeader({
          title: '网速测量',
          stack: this.stack,
          backClick: () => {
            this.vm.setStatusBarContentColor('#000000', this.getUIContext());
          },
        })
      }
      Scroll() {
        Column({ space: StyleConstants.SPACE_16 }) {
          if (this.vm.status === MeasureStatus.WAITING) {
            this.waiting()
          }

          if (this.vm.status === MeasureStatus.GOING) {
            this.going()
          }

          if (this.vm.status === MeasureStatus.OVER) {
            this.over()
          }

          Blank().layoutWeight(1)
        }
      }
      .layoutWeight(1)
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.black'))
    .onReady((ctx) => {
      this.stack = ctx.pathStack;
    }).onBackPressed(() => {
      this.vm.setStatusBarContentColor('#000000', this.getUIContext());
      return false
    });
  }

  @Builder
  waiting() {
    Column() {
      Image($r('app.media.ic_begin_measure'))
        .width(StyleConstants.IMAGE_148)
        .height(StyleConstants.IMAGE_148)
        .onClick(() => {
          this.vm.beginMeasure(this.getUIContext());
        })
    }
    .height('50%')
    .aspectRatio(1)
    .justifyContent(FlexAlign.Center)
    .transition(
      TransitionEffect.asymmetric(
        TransitionEffect.OPACITY,
        TransitionEffect
          .scale({ x: 0, y: 0 })
          .combine(TransitionEffect.OPACITY)
          .animation({ duration: 500 }),
      ),
    )

    if (!this.vm.hasNet) {
      Column({ space: StyleConstants.SPACE_28 }) {
        Image($r('app.media.ic_lose_network'))
          .width(StyleConstants.IMAGE_96)
          .height(StyleConstants.IMAGE_72)

        Text('哎呀，网络跑丢了～')
          .fontColor($r('sys.color.font_on_secondary'))
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Regular)
      }
    }
  }

  @Builder
  going() {
    Column() {
      Column() {
        SpeedGauge({
          value: this.vm.curValue,
          progressColors: this.vm.uploading ? StyleConstants.COLOR_ORANGE : StyleConstants.COLOR_BLUE,
          pointColor: this.vm.uploading ? StyleConstants.COLOR_ORANGE : StyleConstants.COLOR_BLUE,
        })
      }
      .height('50%')
      .aspectRatio(1)
      .justifyContent(FlexAlign.Center)
      .transition(
        TransitionEffect.asymmetric(
          TransitionEffect
            .scale({ x: 0, y: 0 })
            .combine(TransitionEffect.OPACITY)
            .animation({ duration: 500 }),
          TransitionEffect.OPACITY,
        ),
      )

      Column() {
        this.typeBuilder()
      }.margin({ top: StyleConstants.SPACE_24, bottom: StyleConstants.SPACE_24 })

      this.dataBuilder()
    }
  }

  @Builder
  over() {
    Column() {
      Row({ space: StyleConstants.SPACE_8 }) {
        Image($r('app.media.ic_begin_measure'))
          .width(StyleConstants.IMAGE_120)
          .height(StyleConstants.IMAGE_120)
          .onClick(() => {
            this.vm.beginMeasure(this.getUIContext());
          })
        Text(this.vm.desc).textColor2()
      }
      .alignSelf(ItemAlign.Start)
      .margin({ top: StyleConstants.SPACE_8, bottom: StyleConstants.SPACE_24 })

      this.typeBuilder()

      Column() {
        this.dataBuilder()
      }
      .margin({ top: StyleConstants.SPACE_28, bottom: StyleConstants.SPACE_88 })

      this.curvesBuilder()
    }
    .padding({ left: StyleConstants.SPACE_16, right: StyleConstants.SPACE_16 })
  }

  @Builder
  dataBuilder() {
    Row() {
      Column({ space: StyleConstants.SPACE_8 }) {
        Text('时延ms').textColor2()

        Text(this.vm.rttMs > 0 ? this.vm.rttMs.toFixed(0) : '-').textColor3()
      }.layoutWeight(1)

      Column({ space: StyleConstants.SPACE_8 }) {
        Row({ space: StyleConstants.SPACE_8 }) {
          Image($r('app.media.ic_down')).width(StyleConstants.IMAGE_16).height(StyleConstants.IMAGE_16)
          Text('下载Mbps').textColor2()
        }

        Text(this.vm.averageDownData > -1 ? this.vm.averageDownData.toFixed(1) : '-').textColor3()
      }.layoutWeight(1)

      Column({ space: StyleConstants.SPACE_8 }) {
        Row({ space: StyleConstants.SPACE_8 }) {
          Image($r('app.media.ic_up')).width(StyleConstants.IMAGE_16).height(StyleConstants.IMAGE_16)
          Text('上传Mbps').textColor2()
        }

        Text(this.vm.averageUpData > -1 ? this.vm.averageUpData.toFixed(1) : '-').textColor3()
      }.layoutWeight(1)
    }
  }

  @Builder
  typeBuilder() {
    Row() {
      if (this.vm.type === NetworkType.WIFI) {
        Image($r('app.media.ic_wifi')).width(StyleConstants.IMAGE_22).height(StyleConstants.IMAGE_16)
      }
      if (this.vm.type === NetworkType.CELLULAR) {
        Image($r('app.media.ic_cellular')).width(StyleConstants.IMAGE_20).height(StyleConstants.IMAGE_20)
      }

      Text(this.vm.address).textColor1().margin({ left: StyleConstants.SPACE_14, right: StyleConstants.SPACE_8 })

      Text(this.vm.type === NetworkType.WIFI ? 'WIFI网络' : '蜂窝网络').textColor1()
    }
  }

  @Builder
  curvesBuilder() {
    Column({ space: StyleConstants.SPACE_36 }) {
      Column({ space: StyleConstants.SPACE_8 }) {
        Row() {
          Text('下行/Mbps').textColor1()
          Text('已使用' + this.vm.downBytes.toFixed(0) + 'MB').textColor1()
        }
        .width(StyleConstants.FULL_PERCENT)
        .justifyContent(FlexAlign.SpaceBetween)

        SpeedCurve({ data: this.vm.downData, lineColor: StyleConstants.COLOR_BLUE, limit: this.vm.limit })
          .width('90%')
          .aspectRatio(3)
      }

      Column({ space: StyleConstants.SPACE_8 }) {
        Row() {
          Text('上行/Mbps').textColor1()
          Text('已使用' + this.vm.upBytes.toFixed(0) + 'MB').textColor1()
        }
        .width(StyleConstants.FULL_PERCENT)
        .justifyContent(FlexAlign.SpaceBetween)

        SpeedCurve({ data: this.vm.upData, lineColor: StyleConstants.COLOR_ORANGE, limit: this.vm.limit })
          .width('90%')
          .aspectRatio(3)
      }
    }
  }
}

@Extend(Text)
function textColor1() {
  .fontColor($r('sys.color.font_on_secondary'))
  .fontSize($r('sys.float.Body_S'))
  .fontWeight(FontWeight.Regular)
}

@Extend(Text)
function textColor2() {
  .fontColor($r('sys.color.font_on_secondary'))
  .fontSize($r('sys.float.Body_M'))
  .fontWeight(FontWeight.Regular)
}

@Extend(Text)
function textColor3() {
  .fontColor($r('sys.color.font_on_primary'))
  .fontSize($r('sys.float.Body_L'))
  .fontWeight(FontWeight.Regular)
}