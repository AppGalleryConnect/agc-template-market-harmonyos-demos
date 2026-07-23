import { DailyWeather } from '../common/CoreType';
import { StyleConstants } from '../common/StyleConstants';
import { CardContainer } from '../components/CardContainer';
import { CustomCanvas } from '../components/CustomCanvas';
import { CanvasController } from '../utils/CanvasUtil';
import { FontUtil } from '../utils/FontUtil';

@Extend(Text)
function textStyle1() {
  .fontSize(14 * FontUtil.getRate())
  .lineHeight(19 * FontUtil.getRate())
  .fontColor($r('sys.color.font_primary'))
}

@Extend(Text)
function textStyle2() {
  .fontSize(12 * FontUtil.getRate())
  .lineHeight(16 * FontUtil.getRate())
  .fontColor($r('sys.color.font_secondary'))
}

@ComponentV2
export struct UIDays {
  @Require @Param weathers: DailyWeather[];
  @Param maxTemp: number = 46;
  @Param minTemp: number = 16;
  @Param itemWidth: number = 48;
  @Param customHeight: number = 317;
  @Local curIndex: number = 1;
  canvasHeight: number = 120;
  maxController: CanvasController = new CanvasController({
    labelPosition: 'top',
    firstSegmentDashed: true,
    verticalLineStyle: { width: 0 },
    curveColor: '#FBB460',
    holeRadius: 4,
    holeFillColor: '#FBB460',
  });
  minController: CanvasController = new CanvasController({
    labelPosition: 'bottom',
    firstSegmentDashed: true,
    verticalLineStyle: { width: 0 },
    curveColor: '#3F7EF7',
    holeRadius: 4,
    holeFillColor: '#3F7EF7',
  });

  @Computed
  get maxTemps() {
    return this.weathers.map(weather => weather.maxTemp);
  }

  @Computed
  get minTemps() {
    return this.weathers.map(weather => weather.minTemp);
  }

  getWeekDay(s: string): string {
    const parts = s.split('-');
    if (parts.length !== 3) {
      return '';
    }
    const d = new Date(Number(parts[0]), Number(parts[1]) - 1, Number(parts[2]));
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    d.setHours(0, 0, 0, 0);
    const diff = (d.getTime() - today.getTime()) / 86400000 | 0;
    if (diff === -1) {
      return '昨天';
    }
    if (diff === 0) {
      return '今天';
    }
    if (diff === 1) {
      return '明天';
    }
    const w = d.getDay();
    return ['周日', '周一', '周二', '周三', '周四', '周五', '周六'][w];
  }

  getDate(s: string): string {
    const parts = s.split('-');
    if (parts.length !== 3) {
      return '';
    }
    return parts[1] + '/' + parts[2];
  }

  getAirQualityBtnColor(s: string) {
    if (s === '优') {
      return $r('sys.color.confirm');
    } else if (s === '良') {
      return $r('sys.color.multi_color_10');
    } else if (s === '差') {
      return $r('sys.color.multi_color_08');
    }
    return '';
  }

  build() {
    CardContainer({ title: '15天预报' }) {
      Scroll() {
        Stack() {
          CustomCanvas({
            controller: this.maxController,
            list: this.maxTemps,
            max: this.maxTemp,
            min: this.minTemp,
            index: this.curIndex,
            itemWidth: this.itemWidth,
            canvasHeight: this.canvasHeight,
          })
            .margin({ left: StyleConstants.SPACE_16, right: StyleConstants.SPACE_16 })
            .offset({ y: StyleConstants.SPACE_20 })

          CustomCanvas({
            controller: this.minController,
            list: this.minTemps,
            max: this.maxTemp,
            min: this.minTemp,
            index: this.curIndex,
            itemWidth: this.itemWidth,
            canvasHeight: this.canvasHeight,
          })
            .margin({ left: StyleConstants.SPACE_16, right: StyleConstants.SPACE_16 })
            .offset({ y: StyleConstants.SPACE_20 })

          List() {
            ForEach(this.weathers, (item: DailyWeather, index) => {
              this.itemBuilder(index)
            }, (item: DailyWeather, index) => JSON.stringify(item) + '_' + index)
          }
          .lanes(StyleConstants.ONE)
          .listDirection(Axis.Horizontal)
          .margin({ left: StyleConstants.SPACE_16, right: StyleConstants.SPACE_16 })
        }
      }
      .height(this.customHeight)
      .width(StyleConstants.FULL_PERCENT)
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .padding({ bottom: StyleConstants.SPACE_16 })
    }
  }

  @Builder
  itemBuilder(index: number) {
    ListItem() {
      Column() {
        Blank()
          .width(StyleConstants.FULL_PERCENT)
          .height(277)
          .backgroundColor(this.curIndex === index ? 'rgba(63, 126, 247, 0.05)' : Color.Transparent)
          .position({ y: StyleConstants.ZERO, x: StyleConstants.ZERO })

        Text(this.getWeekDay(this.weathers[index].time))
          .textStyle1()
          .margin({ top: StyleConstants.SPACE_8, bottom: StyleConstants.SPACE_4 })
          .opacity(index ? StyleConstants.FULL_OPACITY : StyleConstants.SECOND_LEVEL_OPACITY)

        Text(this.getDate(this.weathers[index].time))
          .textStyle2()
          .opacity(index ? StyleConstants.FULL_OPACITY : StyleConstants.SECOND_LEVEL_OPACITY)

        Text(this.weathers[index].dayDesc)
          .textStyle1()
          .margin({ top: StyleConstants.SPACE_4, bottom: StyleConstants.SPACE_6 })
          .opacity(index ? StyleConstants.FULL_OPACITY : StyleConstants.SECOND_LEVEL_OPACITY)


        Image($r(`app.media.${this.weathers[index].dayIcon}`))
          .width(20)
          .aspectRatio(StyleConstants.ONE)
          .margin({ top: StyleConstants.SPACE_6 })

        Blank().layoutWeight(1)

        Image($r(`app.media.${this.weathers[index].nightIcon}`))
          .width(20)
          .aspectRatio(StyleConstants.ONE)
          .margin({ top: StyleConstants.SPACE_6 })
          .opacity(index ? StyleConstants.FULL_OPACITY : StyleConstants.SECOND_LEVEL_OPACITY)


        Text(this.weathers[index].nightDesc)
          .textStyle1()
          .margin({ top: StyleConstants.SPACE_8, bottom: StyleConstants.SPACE_4 })
          .opacity(index ? StyleConstants.FULL_OPACITY : StyleConstants.SECOND_LEVEL_OPACITY)


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
      if (index) {
        this.curIndex = index;
      }
    })
  }
}
