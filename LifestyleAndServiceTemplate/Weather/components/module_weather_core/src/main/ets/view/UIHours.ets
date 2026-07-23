import { HourlyWeather } from '../common/CoreType';
import { StyleConstants } from '../common/StyleConstants';
import { CardContainer } from '../components/CardContainer';
import { CustomCanvas } from '../components/CustomCanvas';
import { CanvasController } from '../utils/CanvasUtil';
import { FontUtil } from '../utils/FontUtil';

@Extend(Text)
function yAxisTextStyle() {
  .fontSize(12 * FontUtil.getRate())
  .lineHeight(16 * FontUtil.getRate())
  .fontColor($r('sys.color.font_primary'))
}

@Extend(Text)
function xAxisTextStyle() {
  .fontSize(14 * FontUtil.getRate())
  .lineHeight(19 * FontUtil.getRate())
  .fontColor($r('sys.color.font_secondary'))
}

@Extend(Text)
function showTextStyle() {
  .fontSize(14 * FontUtil.getRate())
  .lineHeight(19 * FontUtil.getRate())
  .fontColor($r('sys.color.font_primary'))
}

@Preview
@ComponentV2
export struct UIHours {
  @Require @Param weathers: HourlyWeather[];
  @Param maxTemp: number = 42;
  @Param minTemp: number = 20;
  @Param itemWidth: number = 48;
  @Param customHeight: number = 224;
  @Local curIndex: number = 0;
  @Local showText: string = '';
  canvasHeight: number = 120;
  controller: CanvasController = new CanvasController({ labelPosition: 'none', firstSegmentDashed: false });

  @Computed
  get temps() {
    return this.weathers.map(weather => weather.temp);
  }

  @Monitor('weathers','curIndex')
  private _showChange() {
    this.showText =
      this.weathers[this.curIndex].desc + ' ' + Math.round(this.weathers[this.curIndex].temp) + '° ' + '空气' +
      this.weathers[this.curIndex].airQuality
  }

  aboutToAppear(): void {
    this._showChange();
  }

  getAirQualityBtnColor(s: string) {
    if (s === '优') {
      return $r('sys.color.confirm');
    } else if (s === '良') {
      return $r('sys.color.multi_color_11');
    } else if (s === '差') {
      return $r('sys.color.multi_color_08');
    }
    return '';
  }

  build() {
    CardContainer({ title: '24小时预报' }) {
      Row({ space: StyleConstants.SPACE_8 }) {
        this.yAxis()
        Scroll() {
          Stack() {
            CustomCanvas({
              controller: this.controller,
              list: this.temps,
              max: this.maxTemp,
              min: this.minTemp,
              index: this.curIndex,
              itemWidth: this.itemWidth,
              canvasHeight: this.canvasHeight,
            })

            List() {
              ForEach(this.weathers, (item: HourlyWeather, index) => {
                this.itemBuilder(index)
              }, (item: HourlyWeather, index) => JSON.stringify(item) + '_' + index)
            }
            .lanes(StyleConstants.ONE)
            .listDirection(Axis.Horizontal)

            if (this.showText) {
              Text(this.showText)
                .height(44)
                .padding(12)
                .backgroundColor($r('sys.color.background_primary'))
                .shadow({
                  offsetX: 0,
                  offsetY: 2,
                  radius: 8,
                  color: 'rgba(0, 0, 0, 0.08)',
                })
                .showTextStyle()
                .borderRadius(20)
                .position({
                  left: this.curIndex * this.itemWidth -
                    (this.curIndex === this.weathers.length - 1 ? this.itemWidth + 16 : 0),
                  top: (this.maxTemp - this.weathers[this.curIndex].temp) / (this.maxTemp - this.minTemp) *
                  this.canvasHeight,
                })
            }
          }
        }
        .layoutWeight(StyleConstants.ONE)
        .height(StyleConstants.FULL_PERCENT)
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
      }
      .width(StyleConstants.FULL_PERCENT)
      .height(this.customHeight)
      .padding({ left: StyleConstants.SPACE_16, bottom: StyleConstants.SPACE_16 })
    }
  }

  @Builder
  yAxis() {
    Column() {
      Column() {
        Text(this.maxTemp + '°C').yAxisTextStyle()
        Text(this.minTemp + '°C').yAxisTextStyle()
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.SpaceBetween)

      Text('温度').yAxisTextStyle().height(19).margin({ top: StyleConstants.SPACE_12, bottom: StyleConstants.SPACE_4 })
      Text('空气').yAxisTextStyle().height(19)
    }
    .padding({ top: StyleConstants.SPACE_30 })
    .height(StyleConstants.FULL_PERCENT)
  }

  @Builder
  itemBuilder(index: number) {
    ListItem() {
      Column() {
        Blank()
          .width(StyleConstants.FULL_PERCENT)
          .height(162)
          .backgroundColor(this.curIndex === index ? 'rgba(63, 126, 247, 0.05)' : Color.Transparent)
          .position({ y: 0, x: 0 })

        Text(this.weathers[index].time).xAxisTextStyle().height(19).margin({ top: StyleConstants.SPACE_8 })

        Image($r(`app.media.${this.weathers[index].icon}`))
          .width(20)
          .aspectRatio(StyleConstants.ONE)
          .margin({ top: StyleConstants.SPACE_8 })

        Blank().layoutWeight(1)

        Text(Math.round(this.weathers[index].temp) + '°')
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Body_M'))
          .height(19)
          .margin({ bottom: StyleConstants.SPACE_6 })

        Text(this.weathers[index].airQuality)
          .textAlign(TextAlign.Center)
          .width(32)
          .height(16)
          .borderRadius(StyleConstants.HALF_PERCENT)
          .backgroundColor(this.getAirQualityBtnColor(this.weathers[index].airQuality))
          .fontColor($r('sys.color.font_on_primary'))
          .fontSize($r('sys.float.Caption_M'))
      }
      .width(StyleConstants.FULL_PERCENT)
      .height(StyleConstants.FULL_PERCENT)
    }
    .height(StyleConstants.FULL_PERCENT)
    .width(this.itemWidth)
    .onClick(() => {
      this.curIndex = index;
    })
  }
}
