import { CITY_LIST_SAMPLE, CitySelect, CitySelectController, HOT_CITY_LIST_SAMPLE } from 'city_select';
import { GridRowColSetting, RouterModule } from 'lib_foundation';

@ComponentV2
struct CitySelectPage {
  @Local breakpoint: string = '';
  controller: CitySelectController = new CitySelectController();

  build() {
    NavDestination() {
      GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
        GridCol({ span: GridRowColSetting.GRID_ROW_OPTIONS_COLUMNS, }) {
          Column() {
            CitySelect({
              select: ((city) => {
                RouterModule.pop(city.name)
              }),
              cityList: CITY_LIST_SAMPLE,
              hotCityList: HOT_CITY_LIST_SAMPLE,
              controller: this.controller,
            })
          }
          .width('100%')
        }
      }
      .onBreakpointChange((bp) => {
        this.breakpoint = bp;
      })
    }
    .height('100%')
    .width('100%')
    .title('城市选择', {
      paddingStart: { value: GridRowColSetting.getPageMargin(this.breakpoint), unit: 1 }
    })
    .backgroundColor($r('sys.color.background_secondary'))
    .onBackPressed(() => {
      return this.controller.onBackPressed();
    })
  }
}

@Builder
export function citySelectBuilder(): void {
  CitySelectPage()
}