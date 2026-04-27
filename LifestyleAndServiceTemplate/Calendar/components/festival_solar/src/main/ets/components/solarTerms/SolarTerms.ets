import { BaseTextStyleModifier } from 'base_apis'
import dayjs from 'dayjs'
import { COL_SPAN, GRID_ROW_OPTIONS, GRID_ROW_OPTIONS_Y_8 } from '../../constants/Constants'
import { SolarInfo } from '../../model/model'
import { getSolarInfo } from '../../utils/Utils'

@ComponentV2
export struct SolarTerms {
  /**
   * 传入的日期
   */
  @Param selectedDate: Date = new Date()
  /**
   * 节气信息
   */
  @Local solarInfo: SolarInfo[] = []
  /**
   * 节气卡片事件
   */
  @Event onSolarCardClick: (solarInfo: SolarInfo) => void = () => {
  }

  aboutToAppear(): void {
    this.solarInfo = getSolarInfo(this.selectedDate)
  }

  build() {
    Scroll() {
      Stack({ alignContent: Alignment.TopStart }) {
        GridRow({
          columns: {
            sm: 6,
            md: 8,
            lg: 12,
            xl: 12,
          },
        }) {
          ForEach(this.solarInfo, (item: SolarInfo) => {
            GridCol({
              span: {
                sm: 2,
                md: 2,
                lg: 3,
                xl: 3,
              },
            }) {
              Column({ space: 8 }) {
                Text(item.solarTerm)
                  .attributeModifier(new BaseTextStyleModifier('font_primary/Subtitle_M/Medium'))
                Text(item.solarDate)
                  .attributeModifier(new BaseTextStyleModifier('font_secondary/Body_S/Regular'))
              }
              .onClick(() => {
                this.onSolarCardClick(item)
              })
              .backgroundColor(item.solarDate === dayjs(this.selectedDate).format('YYYY年M月D日') ?
                $r('sys.color.comp_background_tertiary') : $r('sys.color.background_primary'))
              .padding(12)
              .borderRadius(8)
            }

          }, (item: SolarInfo) => JSON.stringify(item))
        }
        .layoutWeight(1)
      }
      .height('100%')
    }
    .scrollBar(BarState.Off)
    .height('100%')
    .padding({ bottom: 16 })
    .edgeEffect(EdgeEffect.Spring)
  }
}
