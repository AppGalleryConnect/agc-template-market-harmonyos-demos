import { UtilLog } from '@hw-agconnect/util-log';
import { CalendarVM, NavigationTitle, TABLET_GRID, TABLE_COL, TABLE_COL_OFFSET } from 'common'
import { FestivalSolar, HolidayInfo, PublicHolidayInfo, SolarInfo } from 'festival_solar';

@Builder
export function FestivalSolarToolsBuilder() {
  FestivalSolarTools()
}

const TAG = '[FestivalSolarTools]'

@ComponentV2
export struct FestivalSolarTools {
  @Local currentIndex: number = 0
  vm: CalendarVM = CalendarVM.instance;

  build() {
    NavDestination() {
      Column() {
        NavigationTitle({
          title: '节日节气',
        })
        GridRow(TABLET_GRID) {
          GridCol({
            span: TABLE_COL,
            offset: TABLE_COL_OFFSET,
          }) {
            FestivalSolar({
              onFestivalCardClick: (festivalInfo: HolidayInfo) => {
                UtilLog.info(TAG, 'onFestivalCardClick', JSON.stringify(festivalInfo))
              },
              onSolarCardClick: (solarInfo: SolarInfo) => {
                UtilLog.info(TAG, 'onSolarCardClick', JSON.stringify(solarInfo))
              },
              onHolidayCardClick: (festivalInfo: PublicHolidayInfo) => {
                UtilLog.info(TAG, 'onHolidayCardClick', JSON.stringify(festivalInfo))
              },
            })
          }
        }
        .layoutWeight(1)
      }
    }
    .hideTitleBar(true)
  }
}