import {
  City,
  CitySelect,
  CitySelectController,
  OVERSEAS_CITY_LIST_SAMPLE,
  OVERSEAS_HOT_CITY_LIST_SAMPLE
} from 'city_select';
import { BarVM, TValueType } from 'common';
import { phoneRouterControl } from 'oh_router';

@Builder
export function OverseasCitySelectPageBuilder(params: TValueType) {
  OverseasCitySelectPage({
    pageParam: params
  })
}

@ComponentV2
struct OverseasCitySelectPage {
  @Param pageParam: TValueType = null
  currentCityName: string = this.pageParam as string
  @Local currentCity: City = {
    name: this.currentCityName,
    code: this.getCityCodeByName(this.currentCityName) as string,
  };
  controller: CitySelectController = new CitySelectController();

  getCityCodeByName(cityName: string): string | undefined {
    const city = OVERSEAS_CITY_LIST_SAMPLE.find(city => city.name === cityName);
    return city?.code;
  }

  build() {
    NavDestination() {
      this.CityBuilder()
    }
    .padding({
      top: BarVM.instance.staBarH,
      bottom: BarVM.instance.aiBarH
    })
    .width('100%')
    .title(`城市选择：${this.currentCity.name}`)
    .onBackPressed(() => {
      phoneRouterControl.popPage({
        popData: this.currentCity
      })
      return true
    })
  }

  @Builder
  CityBuilder() {
    Column() {
      CitySelect({
        select: ((city) => {
          // 选择城市
          this.currentCity = city
        }),
        cancel: () => {},
        handleCurrentCity: (city) => {},
        cityList: OVERSEAS_CITY_LIST_SAMPLE,
        hotCityList: OVERSEAS_HOT_CITY_LIST_SAMPLE,
        controller: this.controller,
      })
    }
    .width('100%')
  }
}
