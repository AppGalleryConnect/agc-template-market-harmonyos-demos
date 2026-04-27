import { BaseCustomTabBar } from 'base_apis'
import { PublicFestival } from '../components/publicFestival/PublicFestival'
import { PublicHolidays } from '../components/publicHolidays/PublicHolidays'
import { SolarTerms } from '../components/solarTerms/SolarTerms'
import { HolidayInfo, PublicHolidayInfo, SolarInfo } from '../model/model'

@ComponentV2
export struct FestivalSolar {
  @Local currentIndex: number = 0
  @Param selectedDate: Date = new Date()
  /**
   * 公众节日卡片事件
   */
  @Event onFestivalCardClick: (festivalInfo: HolidayInfo) => void = () => {}

  /**
   * 节气卡片事件
   */
  @Event onSolarCardClick: (solarInfo: SolarInfo) => void = () => {}

  /**
   * 公众假日卡片事件
   */
  @Event onHolidayCardClick: (festivalInfo: PublicHolidayInfo) => void = () => {}


  build() {
    Column() {
      BaseCustomTabBar({
        currentIndex:this.currentIndex,
        rawSource:'Festival_Tabs_Info.json',
        tabIndexChange:(index:number) => {
          this.currentIndex = index
        }
      })
      Tabs({ barPosition: BarPosition.Start,index:this.currentIndex }) {
        TabContent() {
          PublicFestival({
            onFestivalCardClick:(festivalInfo: HolidayInfo) => {
              this.onFestivalCardClick(festivalInfo)
            }
          })
        }

        TabContent() {
          SolarTerms({
            selectedDate: this.selectedDate,
            onSolarCardClick:(solarInfo: SolarInfo) => {
              this.onSolarCardClick(solarInfo)
            }
          })
        }

        TabContent() {
          PublicHolidays({
            selectedDate: this.selectedDate,
            onHolidayCardClick:(festivalInfo: PublicHolidayInfo) => {
              this.onHolidayCardClick(festivalInfo)
            }
          })
        }
      }
      .onChange((value) => {
        this.currentIndex = value
      })
      .barHeight(0)
      .layoutWeight(1)
    }
    .layoutWeight(1)
  }
}