import { City, CITY_LIST_SAMPLE, CitySelect, CitySelectController, HOT_CITY_LIST_SAMPLE } from 'city_select';
import { BarVM, TValueType } from 'common';
import { phoneRouterControl } from 'oh_router';

@Builder
export function CitySelectPageBuilder(params: TValueType) {
  CitySelectPage({
    pageParam: params
  })
}

phoneRouterControl.registerPageBuilder('CitySelectPage', wrapBuilder(CitySelectPageBuilder))

@ComponentV2
export struct CitySelectPage {
  @Param pageParam: TValueType = null
  currentCityName: string = this.pageParam as string
  @Local currentCity: City = {
    name: this.currentCityName,
    code: this.getCityCodeByName(this.currentCityName) as string,
  };
  controller: CitySelectController = new CitySelectController();

  getCityCodeByName(cityName: string): string | undefined {
    const cityObj = CITY_LIST_SAMPLE.find(city => city.name === cityName);
    return cityObj?.code;
  }

  build() {
    NavDestination() {
      this.CitySelectBuilder()
    }
    .padding({
      top: BarVM.instance.staBarH,
      bottom: BarVM.instance.aiBarH
    })
    .onBackPressed(() => {
      phoneRouterControl.popPage({
        popData: this.currentCity
      })
      return true
    })
    .width('100%')
    .title(`城市选择：${this.currentCity.name}`)
  }

  @Builder
  CitySelectBuilder() {
    Column() {
      CitySelect({
        select: ((city) => {
          // 选择城市
          this.currentCity = city
        }),
        cancel: () => {
          // 取消选择
        },
        handleCurrentCity: (city) => {
          if (city && !this.currentCityName) {
            this.currentCity = city
          }
        },
        cityList: CITY_LIST_SAMPLE,
        hotCityList: HOT_CITY_LIST_SAMPLE,
        controller: this.controller,
      })
    }
    .width('100%')
  }
}
