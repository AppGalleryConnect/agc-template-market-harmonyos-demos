import { RealTimeWeather } from '../common/CoreType';
import { StyleConstants } from '../common/StyleConstants';
import { FontUtil } from '../utils/FontUtil';

@Extend(Text)
function mainStyle(medium: boolean) {
  .fontWeight(medium ? FontWeight.Medium : FontWeight.Regular)
  .fontSize(16 * FontUtil.getRate())
  .lineHeight(21 * FontUtil.getRate())
  .fontColor($r('sys.color.font_primary'))
}

@Extend(Text)
function subStyle() {
  .fontSize($r('sys.float.Body_S'))
  .fontColor($r('sys.color.font_secondary'))
}

@ComponentV2
export struct UINow {
  @Require @Param weather: RealTimeWeather;
  @Param customHeight: number = 232;
  @Param headerMargin: Margin = {};
  @BuilderParam customUi?: () => void;

  build() {
    Column() {
      Column() {
        this.header()
        this.grid()
      }
      .borderRadius(16)
    }
    .backgroundColor($r('sys.color.comp_background_primary'))
    .width(StyleConstants.FULL_PERCENT)
    .padding(12)
    .height(this.customHeight)
  }

  @Builder
  header() {
    Row() {
      Text(this.weather.temp.toFixed() + '°')
        .fontSize($r('sys.float.Display_L'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
      Column({ space: StyleConstants.SPACE_2 }) {
        Text(this.weather.desc + ' 空气' + this.weather.airQuality).mainStyle(false)
        Row({ space: StyleConstants.SPACE_4 }) {
          Text(this.weather.maxTemp + '°/' + this.weather.minTemp + '°').mainStyle(false)
          this.customUi?.()
        }
      }
      .margin({ left: StyleConstants.SPACE_12 })
      .alignItems(HorizontalAlign.Start)

      Blank().layoutWeight(StyleConstants.ONE)
      Image($r(`app.media.${this.weather.icon}`)).height(51).aspectRatio(StyleConstants.ONE)
    }
    .width(StyleConstants.FULL_PERCENT)
    .height(74)
    .margin(this.headerMargin)
  }

  @Builder
  grid() {
    Grid() {
      GridItem() {
        Column({ space: StyleConstants.SPACE_4 }) {
          Text(this.weather.shellTemp + '°C').mainStyle(true)
          Text('体感温度').subStyle()
        }
      }

      GridItem() {
        Column({ space: StyleConstants.SPACE_4 }) {
          Text(this.weather.humidity + '%').mainStyle(true)
          Text('湿度').subStyle()
        }
      }

      GridItem() {
        Column({ space: StyleConstants.SPACE_4 }) {
          Text(this.weather.pressure + 'hPa').mainStyle(true)
          Text('气压').subStyle()
        }
      }

      GridItem() {
        Column({ space: StyleConstants.SPACE_4 }) {
          Text(this.weather.uv + '级 ' + (this.weather.uv === 0 ? '无' : this.weather.uv > 3 ? '强' : '弱'))
            .mainStyle(true)
          Text('紫外线').subStyle()
        }
      }

      GridItem() {
        Column({ space: StyleConstants.SPACE_4 }) {
          Text(this.weather.rain + '%').mainStyle(true)
          Text('降雨概率').subStyle()
        }
      }

      GridItem() {
        Column({ space: StyleConstants.SPACE_4 }) {
          Text(this.weather.windSpeed + '级 ' + this.weather.windDir).mainStyle(true)
          Text('风力风向').subStyle()
        }
      }
    }
    .columnsTemplate('1fr 1fr 1fr')
    .rowsGap(StyleConstants.SPACE_24)
    .borderRadius(12)
    .padding(12)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .width('100%')
    .height(134)
  }
}
