import { IndicesWeather } from '../common/CoreType';
import { StyleConstants } from '../common/StyleConstants';
import { CardContainer } from '../components/CardContainer';
import { FontUtil } from '../utils/FontUtil';

@Extend(Text)
function mainStyle() {
  .fontWeight(FontWeight.Medium)
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
export struct UIIndices {
  @Require @Param weathers: IndicesWeather[];
  @Event click?: (weather: IndicesWeather) => void;
  @Param itemHeight: number = 64;
  @Param itemSpace: number = 8;
  @Param columnsNum: number = 2;

  build() {
    CardContainer({ title: '生活指数' }) {
      Grid() {
        ForEach(this.weathers, (weather: IndicesWeather, index) => {
          this.gridItemBuilder(index)
        }, (weather: IndicesWeather, index) => JSON.stringify(weather) + '_' + index)
      }
      .width(StyleConstants.FULL_PERCENT)
      .height(this.itemHeight * (this.weathers.length / this.columnsNum) +
        this.itemSpace * (this.weathers.length / this.columnsNum - 1) + 12)
      .padding({ left: StyleConstants.SPACE_16, right: StyleConstants.SPACE_16, bottom: StyleConstants.SPACE_12 })
      .columnsTemplate('1fr '.repeat(this.columnsNum))
      .rowsGap(this.itemSpace)
      .columnsGap(this.itemSpace)
    }
  }

  @Builder
  gridItemBuilder(index: number) {
    GridItem() {
      Row() {
        Image($r(`app.media.${this.weathers[index].icon}`)).width(20).aspectRatio(StyleConstants.ONE)
        Column({ space: StyleConstants.SPACE_2 }) {
          Text(this.weathers[index].name).subStyle()
          Text(this.weathers[index].category).mainStyle()
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(StyleConstants.ONE)
        .margin({ left: StyleConstants.SPACE_13 })

        Image($r('app.media.ic_weather_arrow')).height(13).fillColor($r('sys.color.icon_secondary'))
      }
    }
    .width(StyleConstants.FULL_PERCENT)
    .height(this.itemHeight)
    .padding(StyleConstants.SPACE_12)
    .borderRadius(12)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .onClick(() => {
      this.click?.(this.weathers[index]);
    })
  }
}
