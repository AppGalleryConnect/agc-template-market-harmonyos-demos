import { BaseTextStyleModifier, CardAttributeUpdater, CommonConstants, CommonHeader, WindowUtil } from 'lib_foundation';
import { IndicesWeather } from 'module_weather_core';
import { MineVM } from '../viewmodels/MineVM';

@ComponentV2
export struct IndicesPage {
  vm: MineVM = MineVM.instance;
  modifier1: CardAttributeUpdater = new CardAttributeUpdater();
  modifier2: CardAttributeUpdater = new CardAttributeUpdater();

  aboutToAppear(): void {
    this.vm.getIndicesParams();
  }

  build() {
    NavDestination() {
      CommonHeader({ title: '生活指数', subTitle: this.vm.getCurrentDateString() })
        .margin({ bottom: CommonConstants.SPACE_8 })

      if (this.vm.indices.length) {
        this.tabBarBuilder()

        Scroll() {
          Column({ space: CommonConstants.SPACE_12 }) {
            this.todayBuilder()

            this.futureBuilder()

            Blank().layoutWeight(1)
          }
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .layoutWeight(1)
      }
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({ bottom: WindowUtil.getAvoidArea().bottom })
  }

  @Builder
  tabBarBuilder() {
    List({ space: CommonConstants.SPACE_8, initialIndex: this.vm.type - 1 }) {
      ForEach(this.vm.indices[0], (item: IndicesWeather) => {
        ListItem() {
          Row({ space: CommonConstants.SPACE_3 }) {
            Image($r(`app.media.${item.icon}`))
              .fillColor(this.vm.type === item.type ? $r('sys.color.white') : $r('sys.color.icon_secondary'))
              .width(14)
              .aspectRatio(1)

            Text(item.name.slice(0, 2))
              .fontWeight(FontWeight.Medium)
              .fontColor(this.vm.type === item.type ? $r('sys.color.font_on_primary') : $r('sys.color.font_primary'))
              .fontSize($r('sys.float.Body_M'))
          }
          .width(72)
          .height(36)
          .justifyContent(FlexAlign.Center)
        }
        .borderRadius(21)
        .clip(true)
        .backgroundColor(this.vm.type === item.type ? '#3F7EF7' : $r('sys.color.comp_background_tertiary'))
        .onClick(() => {
          this.vm.type = item.type;
        })
      }, (item: IndicesWeather) => item.type.toString())
    }
    .height(60)
    .width(CommonConstants.FULL_PERCENT)
    .padding({ top: CommonConstants.SPACE_12, bottom: CommonConstants.SPACE_12 })
    .contentStartOffset(CommonConstants.SPACE_16)
    .contentEndOffset(CommonConstants.SPACE_16)
    .lanes(1)
    .listDirection(Axis.Horizontal)
    .scrollBar(BarState.Off)
  }

  @Builder
  todayBuilder() {
    Column({ space: CommonConstants.SPACE_12 }) {
      Row() {
        Column({ space: CommonConstants.SPACE_2 }) {
          Text(this.vm.curIndicesTod!.name)
            .attributeModifier(new BaseTextStyleModifier('font_primary/Subtitle_S/Regular'))
          Text(this.vm.curIndicesTod!.category)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Title_M'))
        }
        .alignItems(HorizontalAlign.Start)

        Image($r(`app.media.${this.vm.curIndicesTod!.icon}`)).width(43).height(39)
      }
      .width(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceBetween)

      if (this.vm.weather) {
        this.gridBuilder()
      }

      Text(this.vm.curIndicesTod!.text)
        .attributeModifier(new BaseTextStyleModifier('font_primary/Body_M/Regular'))
        .lineHeight(19)
    }
    .attributeModifier(this.modifier1)
    .onAttach(() => {
      this.modifier1.attribute?.padding({
        left: 12,
        right: 12,
        top: 16,
        bottom: 16,
      }).width('calc(100% - 32vp)')
    })
  }

  @Builder
  futureBuilder() {
    Row() {
      Column({ space: 4 }) {
        Text(this.vm.getWeekDay(this.vm.curIndicesTom!.time))
          .attributeModifier(new BaseTextStyleModifier('font_secondary/Body_S/Regular'))
        Text(this.vm.curIndicesTom!.category)
          .attributeModifier(new BaseTextStyleModifier('font_primary/Body_L/Medium'))
      }
      .layoutWeight(1)

      Column({ space: 4 }) {
        Text(this.vm.getWeekDay(this.vm.curIndicesOverm!.time))
          .attributeModifier(new BaseTextStyleModifier('font_secondary/Body_S/Regular'))
        Text(this.vm.curIndicesOverm!.category)
          .attributeModifier(new BaseTextStyleModifier('font_primary/Body_L/Medium'))
      }
      .layoutWeight(1)
    }
    .border({ width: 0.5, color: $r('sys.color.background_secondary') })
    .attributeModifier(this.modifier2)
    .onAttach(() => {
      this.modifier2.attribute?.width('calc(100% - 32vp)');
    })
  }

  @Builder
  gridBuilder() {
    Column() {
      Grid() {
        GridItem() {
          Column({ space: CommonConstants.SPACE_4 }) {
            Text(this.vm.weather?.desc).mainStyle()
            Text('天气').subStyle()
          }
        }

        GridItem() {
          Column({ space: CommonConstants.SPACE_4 }) {
            Text(this.vm.weather!.maxTemp + '°/' + this.vm.weather!.minTemp + '°').mainStyle()
            Text('温度').subStyle()
          }
        }

        GridItem() {
          Column({ space: CommonConstants.SPACE_4 }) {
            Text(this.vm.weather!.humidity + '%').mainStyle()
            Text('湿度').subStyle()
          }
        }

        GridItem() {
          Column({ space: CommonConstants.SPACE_4 }) {
            Text(this.vm.weather!.uv + '级 ' +
              (this.vm.weather!.uv === 0 ? '无' : this.vm.weather!.uv > 3 ? '强' : '弱'))
              .mainStyle()
            Text('紫外线').subStyle()
          }
        }

        GridItem() {
          Column({ space: CommonConstants.SPACE_4 }) {
            Text(this.vm.weather!.rain + '%').mainStyle()
            Text('降雨概率').subStyle()
          }
        }

        GridItem() {
          Column({ space: CommonConstants.SPACE_4 }) {
            Text(this.vm.weather!.windSpeed + '级 ' + this.vm.weather!.windDir).mainStyle()
            Text('风力风向').subStyle()
          }
        }
      }
      .columnsTemplate('1fr 1fr 1fr')
      .rowsGap(CommonConstants.SPACE_24)
    }
    .borderRadius(12)
    .padding(CommonConstants.SPACE_12)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
  }
}

@Extend(Text)
function mainStyle() {
  .fontWeight(FontWeight.Medium)
  .fontSize($r('sys.float.Body_L'))
  .fontColor($r('sys.color.font_primary'))
}

@Extend(Text)
function subStyle() {
  .fontSize($r('sys.float.Body_S'))
  .fontColor($r('sys.color.font_secondary'))
}

@Builder
export function indicesPageBuilder() {
  IndicesPage()
}